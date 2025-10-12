// lib/features/auth/data/datasources/auth_remote_datasource_mock.dart

import 'package:surabhi/core/data/models/user_model.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/data/models/auth_response_model.dart';
import 'package:surabhi/features/auth/data/models/twofa_request_model.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';

/// Mock implementation of AuthRemoteDataSource for development and testing
/// Simulates API responses with realistic delays
class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  // Simulated network delay
  static const Duration _networkDelay = Duration(milliseconds: 800);

  // Mock user database
  static final Map<String, Map<String, dynamic>> _mockUsers = {
    'admin@gmail.com': {
      'password': 'admin123',
      'user': UserModel(
        userId: '1',
        email: 'admin@gmail.com',
        role: 'admin',
        is2faEnabled: true,
        firstName: 'Admin',
        lastName: 'User',
        phoneNumber: '+1234567890',
        image: null,
      ),
    },
    'employee@gmail.com': {
      'password': 'employee123',
      'user': UserModel(
        userId: '2',
        email: 'employee@gmail.com',
        role: 'employee',
        is2faEnabled: false,
        firstName: 'Employee',
        lastName: 'User',
        phoneNumber: '+1234567891',
        image: null,
      ),
    },
    'preacher@gmail.com': {
      'password': 'preacher123',
      'user': UserModel(
        userId: '3',
        email: 'preacher@gmail.com',
        role: 'preacher',
        is2faEnabled: true,
        firstName: 'Preacher',
        lastName: 'User',
        phoneNumber: '+1234567892',
        image: null,
      ),
    },
  };

  // Mock OTP storage (in real app, this would be server-side)
  static String? _lastGeneratedOTP;
  static String? _lastOTPMethod;

  @override
  Future<AuthResponseModel> login(LoginParams params) async {
    await Future.delayed(_networkDelay);

    final email = params.email.toLowerCase().trim();
    final mockUserData = _mockUsers[email];

    if (mockUserData == null) {
      throw const AuthException(message: 'Invalid email or password');
    }

    if (mockUserData['password'] != params.password) {
      throw const AuthException(message: 'Invalid email or password');
    }

    final user = mockUserData['user'] as UserModel;

    return AuthResponseModel(
      accessToken: 'mock_access_token_${user.userId}_${DateTime.now().millisecondsSinceEpoch}',
      tokenType: 'Bearer',
      refreshToken: 'mock_refresh_token_${user.userId}_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(_networkDelay);
    // Mock logout - just simulate delay
    _lastGeneratedOTP = null;
    _lastOTPMethod = null;
  }

  @override
  Future<TwoFAResponseModel> request2FA(String method) async {
    await Future.delayed(_networkDelay);

    if (method != 'email' && method != 'phone') {
      throw const ServerException(message: 'Invalid 2FA method. Use "email" or "phone".');
    }

    // Generate a mock OTP (in real app, server generates and sends this)
    _lastGeneratedOTP = '123456'; // Fixed OTP for testing
    _lastOTPMethod = method;

    print('🔐 Mock 2FA: Generated OTP: $_lastGeneratedOTP for method: $method');

    return TwoFAResponseModel(
      message: 'OTP sent successfully via $method',
      method: method,
    );
  }

  @override
  Future<VerifyOTPResponseModel> verifyOTP(String otp, String method) async {
    await Future.delayed(_networkDelay);

    if (_lastGeneratedOTP == null) {
      throw const AuthException(message: 'No OTP request found. Please request OTP first.');
    }

    if (_lastOTPMethod != method) {
      throw const AuthException(message: 'OTP method mismatch. Please request OTP again.');
    }

    if (otp != _lastGeneratedOTP) {
      throw const AuthException(message: 'Invalid OTP. Please try again.');
    }

    // Clear OTP after successful verification
    _lastGeneratedOTP = null;
    _lastOTPMethod = null;

    return VerifyOTPResponseModel(
      message: '2FA verification successful',
      verified: true,
    );
  }

  /// Helper method to get mock user for testing
  static UserModel? getMockUser(String email) {
    final mockUserData = _mockUsers[email.toLowerCase().trim()];
    return mockUserData?['user'] as UserModel?;
  }

  /// Helper method to get the last generated OTP (for testing purposes)
  static String? getLastGeneratedOTP() => _lastGeneratedOTP;

  /// Helper method to reset mock state
  static void reset() {
    _lastGeneratedOTP = null;
    _lastOTPMethod = null;
  }
}

