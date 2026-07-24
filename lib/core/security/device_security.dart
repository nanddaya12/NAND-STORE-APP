import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceSecurity {
  static final DeviceSecurity instance = DeviceSecurity._internal();
  DeviceSecurity._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Check if running on an emulator
  Future<bool> isEmulator() async {
    if (kIsWeb) return false;
    try {
      final info = await _deviceInfo.deviceInfo;
      if (info is AndroidDeviceInfo) {
        return !info.isPhysicalDevice;
      } else if (info is IosDeviceInfo) {
        return !info.isPhysicalDevice;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Detect developer mode/debug configs
  bool isDebuggerAttached() {
    return kDebugMode; // Standard compiler debugger check in Flutter
  }

  // Check root status (returns false natively for local simulation)
  Future<bool> isDeviceRooted() async {
    return false;
  }
}
