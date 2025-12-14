// lib/core/services/security_service.dart

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:surabhi/features/auth/repositories/auth_repository.dart';

enum SecurityMethod { biometric, otp, none }

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthRepository _authRepository;

  SecurityService(this._authRepository);

  /// Decides which security method to use based on Platform
  Future<SecurityMethod> getAvailableMethod() async {
    if (kIsWeb) {
      // Force OTP for Web
      return SecurityMethod.otp;
    }

    try {
      final bool canAuth = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      return canAuth ? SecurityMethod.biometric : SecurityMethod.none;
    } catch (e) {
      return SecurityMethod.none;
    }
  }

  /// Mobile: Triggers FaceID/Fingerprint
  Future<bool> authenticateBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }

  /// Web: Triggers Backend OTP
  Future<void> triggerWebOtp(String email) async {
    // Reusing your existing UseCase
    await _authRepository.sendTwoFactorCode(email, 'Email',);
  }
}
