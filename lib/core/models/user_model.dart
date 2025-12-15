// lib/core/models/user_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:surabhi/core/constants/app_constants.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String? code;
  final String? mobileNumber;
  final String email;
  final Role role;

  final String? name;
  final String? avatar;
  final String? avatarContentType;

  const UserModel({
    required this.id,
    this.code,
    this.mobileNumber,
    required this.email,
    required this.role,
    this.name,
    this.avatar,
    this.avatarContentType,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get displayName => name ?? email;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get avatarInitial => name?.isNotEmpty ?? false ? name![0] : email[0];
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get phoneNumber => mobileNumber ?? '';

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
