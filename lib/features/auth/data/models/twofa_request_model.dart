// lib/features/auth/data/models/twofa_request_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'twofa_request_model.g.dart';

@JsonSerializable()
class TwoFARequestModel {
  @JsonKey(name: 'method')
  final String method; // 'email' or 'phone'

  TwoFARequestModel({required this.method});

  factory TwoFARequestModel.fromJson(Map<String, dynamic> json) =>
      _$TwoFARequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TwoFARequestModelToJson(this);
}

@JsonSerializable()
class TwoFAResponseModel {
  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'method')
  final String method;

  TwoFAResponseModel({required this.message, required this.method});

  factory TwoFAResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TwoFAResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TwoFAResponseModelToJson(this);
}

@JsonSerializable()
class VerifyOTPRequestModel {
  @JsonKey(name: 'otp')
  final String otp;

  @JsonKey(name: 'method')
  final String method;

  VerifyOTPRequestModel({required this.otp, required this.method});

  factory VerifyOTPRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOTPRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOTPRequestModelToJson(this);
}

@JsonSerializable()
class VerifyOTPResponseModel {
  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'verified')
  final bool verified;

  VerifyOTPResponseModel({required this.message, required this.verified});

  factory VerifyOTPResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOTPResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOTPResponseModelToJson(this);
}

