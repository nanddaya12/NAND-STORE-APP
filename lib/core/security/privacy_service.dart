import 'package:flutter/services.dart';

class PrivacyService {
  static final PrivacyService instance = PrivacyService._internal();
  PrivacyService._internal();

  // Clear system clipboard to prevent third-party reading
  Future<void> clearClipboard() async {
    try {
      await Clipboard.setData(const ClipboardData(text: ''));
    } catch (e) {
      // ignore
    }
  }

  // Prevent screenshots and screen recording on Android/iOS (simulate channel boundaries)
  Future<void> setSecureScreen(bool enabled) async {
    const channel = MethodChannel('com.nandstore.app/security');
    try {
      await channel.invokeMethod('setSecureScreen', {'enabled': enabled});
    } catch (e) {
      // Platform channels not registered on this dev sandbox
    }
  }
}
