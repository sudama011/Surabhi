// lib/core/domain/entities/user_entity.dart

class UserEntity {
  final String id;
  final String userName;
  final String role;
  final String? phoneNumber;

  final String? firstName;
  final String? lastName;
  final String? image;
  final bool? emailVerified;
  final bool? phoneVerified;

  const UserEntity({
    required this.id,
    required this.userName,
    required this.role,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.image,
    this.emailVerified,
    this.phoneVerified,
  });
}
