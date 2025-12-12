// lib/features/admin/devotees/domain/entities/devotee_entity.dart

class DevoteeEntity {
  final int id;
  final String name;
  final String code;
  final String mobileNumber;
  final String email;
  final String? avatar;
  final String? avatarContentType;

  DevoteeEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.mobileNumber,
    required this.email,
    this.avatar,
    this.avatarContentType,
  });

  factory DevoteeEntity.fromJson(Map<String, dynamic> json) {
    return DevoteeEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      avatarContentType: json['avatarContentType'] as String?,
    );
  }
}
