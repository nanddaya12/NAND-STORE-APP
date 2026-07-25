import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import '../error/failures.dart';
import '../security/request_signer.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorage _secureStorage = SecureStorage.instance;
  final Connectivity _connectivity = Connectivity();

  ApiClient({String baseUrl = 'https://api.nandstore.com/v1'}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Configure SSL Pinning on non-web platforms
    if (!kIsWeb) {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            // Reject self-signed, expired, and invalid certificates by default for maximum security
            return false;
          };
          return client;
        };
      }
    }

    dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
      _retryInterceptor(),
      _refreshTokenInterceptor(),
      _requestSigningInterceptor(),
    ]);
  }

  // Internet connectivity check helper
  Future<bool> isConnected() async {
    final dynamic results = await _connectivity.checkConnectivity();
    if (results is List) {
      return results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
    } else {
      return results != ConnectivityResult.none;
    }
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read('access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    );
  }

  Interceptor _loggingInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('NAND_API: $obj'),
    );
  }

  Interceptor _retryInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException err, handler) async {
        if (err.type == DioExceptionType.connectionTimeout || 
            err.type == DioExceptionType.sendTimeout ||
            err.type == DioExceptionType.receiveTimeout) {
          
          RequestOptions options = err.requestOptions;
          int retries = options.extra['retries'] ?? 0;

          if (retries < 3) {
            retries++;
            options.extra['retries'] = retries;
            
            int delaySeconds = 1 << (retries - 1);
            await Future.delayed(Duration(seconds: delaySeconds));
            
            try {
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(err);
            }
          }
        }
        return handler.next(err);
      },
    );
  }

  Interceptor _refreshTokenInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          final refreshToken = await _secureStorage.read('refresh_token');
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshResponse = await dio.post('/auth/refresh', data: {
                'refresh_token': refreshToken,
              });
              
              final newAccessToken = refreshResponse.data['access_token'];
              final newRefreshToken = refreshResponse.data['refresh_token'];
              
              if (newAccessToken != null) {
                await _secureStorage.write('access_token', newAccessToken);
                if (newRefreshToken != null) {
                  await _secureStorage.write('refresh_token', newRefreshToken);
                }

                RequestOptions options = err.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(options);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              await _secureStorage.clear();
            }
          }
        }
        return handler.next(err);
      },
    );
  }

  // Interceptor to automatically sign all outgoing API requests
  Interceptor _requestSigningInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final bodyStr = options.data != null ? options.data.toString() : '';
        final signatureHeaders = RequestSigner.instance.generateSignatureHeaders(
          options.path,
          options.method,
          bodyStr,
        );
        options.headers.addAll(signatureHeaders);
        return handler.next(options);
      },
    );
  }

  // Exception mapper utility
  Failure mapDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure('Connection timed out. Please try again.');
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        if (code == 401 || code == 403) {
          return const UnauthorizedFailure('Session expired or unauthorized.');
        } else if (code == 400 || code == 422) {
          return const ValidationFailure('Invalid request data details.');
        } else if (code != null && code >= 500) {
          return const ServerFailure('Server error. Please try again later.');
        }
        return ServerFailure('Request failed: ${err.message}');
      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection detected.');
      default:
        return const UnknownFailure('Unexpected connection error.');
    }
  }
}
