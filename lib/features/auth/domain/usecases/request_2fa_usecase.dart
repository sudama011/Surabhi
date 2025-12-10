// lib/features/auth/domain/usecases/request_2fa_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/usecases/usecase.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';

/// Request 2FA code to be sent via email or phone
class Request2FAUseCase implements UseCase<String, Request2FAParams> {
  final AuthRepository repository;

  Request2FAUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(Request2FAParams params) async {
    // Call the repository to send 2FA code
    final result = await repository.sendTwoFactorCode(params.email, params.method);
    return result.fold((failure) => Left(failure), (_) => const Right('2FA code sent successfully'));
  }
}

class Request2FAParams extends Equatable {
  final String email;
  final String method; // 'email' or 'phone'

  const Request2FAParams({required this.email, required this.method});

  @override
  List<Object> get props => [email, method];
}
