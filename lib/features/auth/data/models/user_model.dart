// lib/core/data/models/user_model.dart

import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String? code;
  final String? mobileNumber;
  final String email;

  final String? name;
  final String? avatar;
  final String? avatarContentType;

  final bool? emailVerified;
  final bool? mobileVerified;

  const UserModel({
    required this.id,
    this.code,
    this.mobileNumber,
    required this.email,
    this.name,
    this.avatar,
    this.avatarContentType,
    this.emailVerified,
    this.mobileVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
