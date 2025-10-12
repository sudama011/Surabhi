// lib/features/auth/domain/usecases/verify_otp_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/usecases/usecase.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';

class VerifyOTPUseCase implements UseCase<bool, VerifyOTPParams> {
  final AuthRepository repository;

  VerifyOTPUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyOTPParams params) async {
    return await repository.verifyOTP(params.otp, params.method);
  }
}

class VerifyOTPParams extends Equatable {
  final String otp;
  final String method;

  const VerifyOTPParams({required this.otp, required this.method});

  @override
  List<Object> get props => [otp, method];
}

