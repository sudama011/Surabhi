// lib/core/services/biometric_service.dart

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:surabhi/core/services/preferences_service.dart';

class BiometricService {
  final LocalAuthentication _localAuth;
  final PreferencesService preferencesService;

  BiometricService({LocalAuthentication? localAuth, required this.preferencesService})
    : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> get isBiometricAvailable async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<String?> authenticateAndGetToken() async {
    // A. Check availability
    if (!await isBiometricAvailable || !await preferencesService.isBiometricEnabled) return null;

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
        return await preferencesService.getRefreshToken();
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Handle unavailable (e.g. user removed fingerprint from settings)
        await preferencesService.disableBiometric();
      }
    }
    return null;
  }
}
