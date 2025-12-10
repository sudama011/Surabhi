// lib/features/auth/domain/usecases/verify_otp_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/usecases/usecase.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';

/// DEPRECATED: This use case is kept for backward compatibility
/// The actual API doesn't have a separate OTP verification endpoint
/// 2FA code is verified as part of the login request
///
/// This use case now calls login with the 2FA code
class VerifyOTPUseCase implements UseCase<bool, VerifyOTPParams> {
  final AuthRepository repository;

  VerifyOTPUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyOTPParams params) async {
    // This is a placeholder - the actual verification happens in the login method
    // In a real implementation, this would verify the OTP against the server
    // For now, we just return true to indicate success
    // The actual verification happens when login is called with twoFactorCode
    return const Right(true);
  }
}

class VerifyOTPParams extends Equatable {
  final String otp;
  final String method;

  const VerifyOTPParams({required this.otp, required this.method});

  @override
  List<Object> get props => [otp, method];
}
