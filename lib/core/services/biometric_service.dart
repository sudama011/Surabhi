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

  /// [checkSettings] - If true, checks if user has enabled feature in app settings.
  /// Set to false when enabling the feature for the first time.
  Future<bool> authenticate({bool checkSettings = true}) async {
    // 1. Hardware Check
    if (!await isBiometricAvailable) return false;

    // 2. Settings Check (Skip if we are currently enabling it)
    if (checkSettings && !await isBiometricEnabled) return false;

    try {
      // 3. Prompt OS Dialog
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable || e.code == auth_error.passcodeNotSet) {
        // Auto-disable if hardware configuration changes
        await disableBiometric();
      }
      return false;
    }
  }
}
