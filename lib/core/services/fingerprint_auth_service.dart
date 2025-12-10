// lib/core/services/fingerprint_auth_service.dart

import 'package:local_auth/local_auth.dart';

/// Service for handling fingerprint/biometric authentication
class FingerprintAuthService {
  final LocalAuthentication _localAuth;

  FingerprintAuthService({LocalAuthentication? localAuth}) : _localAuth = localAuth ?? LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      // Silently fail - device doesn't support biometrics
      return false;
    }
  }

  /// Check if device has biometric enrolled
  Future<bool> deviceSupportsFingerprint() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      // Silently fail - device doesn't support biometrics
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      // Silently fail - return empty list
      return [];
    }
  }

  /// Authenticate with fingerprint
  Future<bool> authenticate() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      return isAuthenticated;
    } catch (e) {
      // Authentication failed or was cancelled
      return false;
    }
  }

  /// Authenticate with custom message
  Future<bool> authenticateWithMessage(String message) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: message,
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      return isAuthenticated;
    } catch (e) {
      // Authentication failed or was cancelled
      return false;
    }
  }
}
