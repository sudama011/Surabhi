// lib/core/domain/entities/user_entity.dart

import 'package:json_annotation/json_annotation.dart';
part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity {
  final int id;
  final String? code;
  final String role;
  final String? mobileNumber;
  final String email;

  final String? name;
  final String? avatar;
  final String? avatarContentType;

  final bool? emailVerified;
  final bool? mobileVerified;

  const UserEntity({
    required this.id,
    this.code,
    required this.role,
    this.mobileNumber,
    required this.email,
    this.name,
    this.avatar,
    this.avatarContentType,
    this.emailVerified,
    this.mobileVerified,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get displayName => name ?? email;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get avatarInitial => name?.isNotEmpty ?? false ? name![0] : email[0];

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UserEntityToJson(this);
}
