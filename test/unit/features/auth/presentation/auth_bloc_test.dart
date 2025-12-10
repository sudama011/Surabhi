import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';
import 'package:surabhi/features/auth/domain/usecases/request_2fa_usecase.dart';
import 'package:surabhi/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([LoginUseCase, AuthRepository, Request2FAUseCase, VerifyOTPUseCase])
void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockAuthRepository mockAuthRepository;
  late MockRequest2FAUseCase mockRequest2FAUseCase;
  late MockVerifyOTPUseCase mockVerifyOTPUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockAuthRepository = MockAuthRepository();
    mockRequest2FAUseCase = MockRequest2FAUseCase();
    mockVerifyOTPUseCase = MockVerifyOTPUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      authRepository: mockAuthRepository,
      request2FAUseCase: mockRequest2FAUseCase,
      verifyOTPUseCase: mockVerifyOTPUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testUser = UserEntity(userId: '1', email: 'test@example.com', role: 'admin');

    const testLoginParams = LoginParams(email: 'test@example.com', password: 'password123');

    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('LoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login succeeds',
        build: () {
          when(mockLoginUseCase(testLoginParams)).thenAnswer((_) async => const Right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(email: 'test@example.com', password: 'password123')),
        expect: () => [AuthLoading(), const AuthAuthenticated(user: testUser)],
        verify: (_) {
          verify(mockLoginUseCase(testLoginParams)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when login fails',
        build: () {
          when(
            mockLoginUseCase(testLoginParams),
          ).thenAnswer((_) async => const Left(AuthFailure(message: 'Invalid credentials')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(email: 'test@example.com', password: 'password123')),
        expect: () => [AuthLoading(), const AuthUnauthenticated(message: 'Invalid credentials')],
      );
    });

    group('AppStarted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is already logged in',
        build: () {
          when(mockAuthRepository.checkAuthStatus()).thenAnswer((_) async => const Right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(AppStarted()),
        expect: () => [AuthLoading(), const AuthAuthenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no user is logged in',
        build: () {
          when(
            mockAuthRepository.checkAuthStatus(),
          ).thenAnswer((_) async => const Left(AuthFailure(message: 'No user found')));
          return authBloc;
        },
        act: (bloc) => bloc.add(AppStarted()),
        expect: () => [AuthLoading(), const AuthUnauthenticated()],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when logout succeeds',
        build: () {
          when(mockAuthRepository.logout()).thenAnswer((_) async => const Right(true));
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [const AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] even when logout fails',
        build: () {
          when(
            mockAuthRepository.logout(),
          ).thenAnswer((_) async => const Left(ServerFailure(message: 'Logout failed')));
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [const AuthUnauthenticated()],
      );
    });
  });
}
