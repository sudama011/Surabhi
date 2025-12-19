// lib/core/services/biometric_service.dart

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;
  static const String _biometricEnabledKey = 'is_biometric_enabled';

  BiometricService(this._localAuth, this._secureStorage);

  Future<bool> get isBiometricAvailable async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<void> enableBiometric() async {
    await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
  }

  Future<void> disableBiometric() async {
    await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
  }

  Future<bool> get isBiometricEnabled async {
    final val = await _secureStorage.read(key: _biometricEnabledKey);
    return val == 'true';
  }

  Future<bool> authenticate() async {
    // A. Check availability
    if (!await isBiometricAvailable || !await isBiometricEnabled) return false;

    try {
      // B. Prompt OS Biometric Dialog
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // Forces FaceID/Fingerprint (no PIN fallback if preferred)
        ),
      );

      if (didAuthenticate) {
        // C. If success, return the secret token
        return true;
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Handle unavailable (e.g. user removed fingerprint from settings)
        await disableBiometric();
      }
    }
    return false;
  }
}
