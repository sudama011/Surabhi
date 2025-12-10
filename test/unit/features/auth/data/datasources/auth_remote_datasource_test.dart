import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';

import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient, Dio])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(mockApiClient.dio).thenReturn(mockDio);
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

  group('AuthRemoteDataSource', () {
    const testParams = LoginParams(email: 'test@example.com', password: 'password123');

    group('login', () {
      test('should return AuthResponseModel when login is successful', () async {
        // Arrange
        final responseData = {
          'accessToken': 'access_token_123',
          'tokenType': 'bearer',
          'refreshToken': 'refresh_token_123',
          'expiresIn': 3600,
        };

        when(
          mockDio.post(
            ApiConstants.loginPath,
            data: {'email': testParams.email, 'password': testParams.password},
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.loginPath),
          ),
        );

        // Act
        final result = await dataSource.login(testParams);

        // Assert
        expect(result.token, equals('access_token_123'));
        expect(result.refreshToken, equals('refresh_token_123'));
        expect(result.succeeded, equals(true));
        expect(result.roles, isNotEmpty);

        verify(
          mockDio.post(
            ApiConstants.loginPath,
            data: {'email': testParams.email, 'password': testParams.password},
            options: anyNamed('options'),
          ),
        ).called(1);
      });

      test('should throw AuthException when login fails with 401', () async {
        // Arrange
        final dioError = DioException(
          response: Response(
            data: {'message': 'Invalid credentials'},
            statusCode: 401,
            requestOptions: RequestOptions(path: ApiConstants.loginPath),
          ),
          requestOptions: RequestOptions(path: ApiConstants.loginPath),
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post(ApiConstants.loginPath, data: anyNamed('data'), options: anyNamed('options')),
        ).thenThrow(dioError);

        // Act & Assert
        expect(
          () => dataSource.login(testParams),
          throwsA(isA<AuthException>().having((e) => e.message, 'message', 'Invalid credentials')),
        );
      });

      test('should throw AuthException when login fails with 400', () async {
        // Arrange
        final dioError = DioException(
          response: Response(
            data: {'message': 'Bad request'},
            statusCode: 400,
            requestOptions: RequestOptions(path: ApiConstants.loginPath),
          ),
          requestOptions: RequestOptions(path: ApiConstants.loginPath),
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post(ApiConstants.loginPath, data: anyNamed('data'), options: anyNamed('options')),
        ).thenThrow(dioError);

        // Act & Assert
        expect(() => dataSource.login(testParams), throwsA(isA<AuthException>()));
      });

      test('should throw ServerException when unexpected error occurs', () async {
        // Arrange
        when(
          mockDio.post(ApiConstants.loginPath, data: anyNamed('data'), options: anyNamed('options')),
        ).thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(() => dataSource.login(testParams), throwsA(isA<ServerException>()));
      });
    });

    group('logout', () {
      test('should complete successfully', () async {
        // Note: API doesn't have a logout endpoint, so logout just clears local state
        // Act & Assert
        expect(() => dataSource.logout(), returnsNormally);
      });
    });
  });
}
