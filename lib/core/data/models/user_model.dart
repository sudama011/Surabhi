// lib/core/data/models/user_model.dart

import 'package:surabhi/core/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.userName,
    required super.role,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.image,
    super.emailVerified,
    super.phoneVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    userName: json['userName'] as String,
    role: json['roles'] as String,
    phoneNumber: json['phoneNumber'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'roles': role,
    'phoneNumber': phoneNumber,
  };
}
