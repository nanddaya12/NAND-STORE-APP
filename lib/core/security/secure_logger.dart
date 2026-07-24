import 'package:flutter/foundation.dart';

class SecureLogger {
  static final SecureLogger instance = SecureLogger._internal();
  SecureLogger._internal();

  final List<String> _piiPatterns = [
    'password',
    'access_token',
    'refresh_token',
    'card_number',
    'cvv',
    'pin',
  ];

  // Log debug messages filtering sensitive PII patterns
  void log(String message) {
    if (!kDebugMode) return;
    
    String sanitized = message;
    for (final pattern in _piiPatterns) {
      if (sanitized.toLowerCase().contains(pattern)) {
        // Sanitize value details from the console stream
        sanitized = sanitized.replaceAll(
          RegExp('$pattern\\s*[:=]\\s*\\S+', caseSensitive: false),
          '$pattern: [REDACTED_SECURE]',
        );
      }
    }
    
    debugPrint('NAND_SECURE_LOG: $sanitized');
  }
}
