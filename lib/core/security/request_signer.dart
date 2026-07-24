import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class RequestSigner {
  static final RequestSigner instance = RequestSigner._internal();
  RequestSigner._internal();

  // Generate secure random nonce
  String _generateNonce() {
    final values = List<int>.generate(16, (i) => Random.secure().nextInt(256));
    return base64Url.encode(values);
  }

  // Generate headers map for signing requests
  Map<String, String> generateSignatureHeaders(String path, String method, String? body) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = _generateNonce();
    final requestId = 'req-${Random.secure().nextInt(1000000)}';

    // Signature payload base string
    final payload = '$method|$path|$timestamp|$nonce|$requestId|${body ?? ""}';
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, utf8.encode('NAND_STORE_REQUEST_SIGNING_SECRET_KEY'));
    final digest = hmac.convert(bytes);

    return {
      'X-Signature': digest.toString(),
      'X-Nonce': nonce,
      'X-Timestamp': timestamp,
      'X-Request-ID': requestId,
    };
  }
}
