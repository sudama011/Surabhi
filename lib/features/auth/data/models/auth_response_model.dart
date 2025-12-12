// lib/features/auth/data/models/auth_response_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final bool succeeded;
  final String token;
  final DateTime expiresAt;
  final bool requiresTwoFactor;
  final List<String>? providers;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final List<String> roles;

  AuthResponseModel({
    required this.succeeded,
    required this.token,
    required this.expiresAt,
    required this.requiresTwoFactor,
    this.providers,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.roles,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
