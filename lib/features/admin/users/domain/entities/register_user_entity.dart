// lib/core/domain/entities/user_entity.dart

import 'package:json_annotation/json_annotation.dart';
part 'register_user_entity.g.dart';

@JsonSerializable()
class RegisterUserEntity {
  final String id;
  
  @JsonKey(name: 'roles')
  final String role;

  @JsonKey(name: 'phoneNumber')
  final String? mobileNumber;
  
  @JsonKey(name: 'userName')
  final String email;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get avatarInitial => email.isNotEmpty ? email[0].toUpperCase() : '?';


  const RegisterUserEntity({
    required this.id,
    required this.role,
    this.mobileNumber,
    required this.email
  });

  factory RegisterUserEntity.fromJson(Map<String, dynamic> json) => _$RegisterUserEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterUserEntityToJson(this);
}
