// lib/features/auth/data/models/auth_response_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:surabhi/core/data/models/user_model.dart';

part 'auth_response_model.g.dart';

/// Matches API schema: LoginResponse
/// Response from POST /api/Account/login
@JsonSerializable()
class AuthResponseModel {
  final bool succeeded;

  @JsonKey(name: 'token')
  final String token;

  @JsonKey(name: 'expiresAt')
  final DateTime expiresAt;

  @JsonKey(name: 'requiresTwoFactor')
  final bool requiresTwoFactor;

  @JsonKey(name: 'providers')
  final List<String>? providers;

  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  @JsonKey(name: 'refreshTokenExpiresAt')
  final DateTime refreshTokenExpiresAt;

  @JsonKey(name: 'roles')
  final List<String> roles;

  // User data is not part of the API response, but we include it for app logic
  // This will be populated from a separate endpoint or stored locally
  @JsonKey(includeFromJson: false, includeToJson: false)
  final UserModel? user;

  AuthResponseModel({
    required this.succeeded,
    required this.token,
    required this.expiresAt,
    required this.requiresTwoFactor,
    this.providers,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.roles,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
