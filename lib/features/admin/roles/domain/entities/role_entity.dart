// lib/features/admin/roles/domain/entities/role_entity.dart

class RoleEntity {
  final String id;
  final String name;
  final String? description;

  RoleEntity({required this.id, required this.name, this.description});

  factory RoleEntity.fromJson(Map<String, dynamic> json) {
    return RoleEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}
