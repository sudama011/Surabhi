// lib/core/services/security_service.dart

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:surabhi/features/auth/domain/usecases/request_2fa_usecase.dart';

enum SecurityMethod { biometric, otp, none }

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Request2FAUseCase _request2FAUseCase;

  SecurityService(this._request2FAUseCase);

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
    await _request2FAUseCase(Request2FAParams(email: email, method: 'email')); // or 'authenticator'
  }
}
