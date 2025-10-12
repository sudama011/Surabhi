// lib/features/auth/domain/usecases/request_2fa_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/usecases/usecase.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';

class Request2FAUseCase implements UseCase<String, Request2FAParams> {
  final AuthRepository repository;

  Request2FAUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(Request2FAParams params) async {
    return await repository.request2FA(params.method);
  }
}

class Request2FAParams extends Equatable {
  final String method; // 'email' or 'phone'

  const Request2FAParams({required this.method});

  @override
  List<Object> get props => [method];
}

