// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'A server error occurred.'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Please check your internet connection.'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed. Invalid credentials.'});
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'You do not have permission to perform this action.'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'A caching error occurred.'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation failed. Please check your input.'});
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({super.message = 'Rate limit exceeded. Please try again later.'});
}

class ConflictFailure extends Failure {
  const ConflictFailure({super.message = 'Conflict. The resource already exists.'});
}

class UnhandledFailure extends Failure {
  const UnhandledFailure({super.message = 'An unhandled error occurred.'});
}
