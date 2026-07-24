import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  static final BiometricService instance = BiometricService._internal();
  BiometricService._internal();

  // Check if biometrics is supported on the hardware device
  Future<bool> isBiometricsAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (e) {
      return false;
    }
  }

  // Trigger Face ID or Fingerprint login authentication dialog
  Future<bool> authenticateUser({String message = 'Authenticate to access NAND Store'}) async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: message,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }
}
