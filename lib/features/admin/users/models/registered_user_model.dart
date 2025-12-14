// lib/core/models/registered_user_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:surabhi/core/constants/app_constants.dart';
part 'registered_user_model.g.dart';

@JsonSerializable()
class RegisteredUserModel {
  final String id;

  final String? name;

  @JsonKey(name: 'userName')
  final String email;

  final String? phoneNumber;

  @JsonKey(name: 'roles')
  final Role role;

  const RegisteredUserModel({required this.id, this.name, required this.email, this.phoneNumber, required this.role});

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get displayName => name ?? email;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get avatarInitial => email.isNotEmpty ? email[0].toUpperCase() : '?';

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get mobileNumber => phoneNumber ?? '';

  factory RegisteredUserModel.fromJson(Map<String, dynamic> json) => _$RegisteredUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisteredUserModelToJson(this);

  copyWith({String? id, String? email, String? phoneNumber, Role? role}) {
    return RegisteredUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }
}
