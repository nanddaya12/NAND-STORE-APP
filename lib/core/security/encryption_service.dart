import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  static final EncryptionService instance = EncryptionService._internal();
  EncryptionService._internal();

  // AES-256 Encryption
  String encrypt(String plainText, String keyString) {
    final key = enc.Key.fromUtf8(keyString.padRight(32, ' ').substring(0, 32));
    final iv = enc.IV.fromLength(16); // Standard 16-byte initialization vector
    final encrypter = enc.Encrypter(enc.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  // AES-256 Decryption
  String decrypt(String cipherText, String keyString) {
    final key = enc.Key.fromUtf8(keyString.padRight(32, ' ').substring(0, 32));
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key));

    final decrypted = encrypter.decrypt64(cipherText, iv: iv);
    return decrypted;
  }

  // SHA-256 Hashing for password mapping or integrity checks
  String hashSha256(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Secure random key generation
  String generateSecureRandomKey() {
    final key = enc.Key.fromSecureRandom(32);
    return base64.encode(key.bytes);
  }
}
