import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static final SecureStorageService instance = SecureStorageService._internal();
  SecureStorageService._internal();

  // Save string values
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  // Read string values
  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  // Delete key
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Clear all secure storage parameters
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }

  // Generate or retrieve the encryption key for Hive boxes
  Future<List<int>> getHiveEncryptionKey() async {
    const keyName = 'hive_encryption_key_aes';
    final storedKey = await _secureStorage.read(key: keyName);
    if (storedKey != null) {
      return base64Url.decode(storedKey);
    } else {
      final newKey = Hive.generateSecureKey();
      await _secureStorage.write(key: keyName, value: base64Url.encode(newKey));
      return newKey;
    }
  }
}
