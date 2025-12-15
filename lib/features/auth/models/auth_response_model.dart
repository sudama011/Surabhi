// lib/features/auth/models/auth_response_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/features/auth/models/twofa_provider_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final bool succeeded;
  final String? token;
  final DateTime? expiresAt;
  final bool requiresTwoFactor;
  final List<TwoFAProvider>? providers;
  final String refreshToken;
  final DateTime? refreshTokenExpiresAt;
  final UserModel? profile;

  AuthResponseModel({
    required this.succeeded,
    this.token,
    this.expiresAt,
    required this.requiresTwoFactor,
    this.providers,
    required this.refreshToken,
    this.refreshTokenExpiresAt,
    this.profile,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
