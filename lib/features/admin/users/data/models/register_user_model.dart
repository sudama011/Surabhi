// lib/core/data/models/user_model.dart

import 'package:json_annotation/json_annotation.dart';
part 'register_user_model.g.dart';

@JsonSerializable()
class RegisterUserModel {
  final String id;
  final String userName;
  final String? phoneNumber;
  final String? roles;

  const RegisterUserModel({
    required this.id,
    required this.userName,
    this.phoneNumber,
    this.roles,
  });

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) => _$RegisterUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterUserModelToJson(this);
}
