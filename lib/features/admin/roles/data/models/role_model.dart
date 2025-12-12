// lib/features/admin/roles/data/models/role_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:surabhi/features/admin/roles/domain/entities/role_entity.dart';

part 'role_model.g.dart';

@JsonSerializable()
class RoleModel extends RoleEntity {
  RoleModel({required super.id, required super.name, super.description});

  factory RoleModel.fromJson(Map<String, dynamic> json) => _$RoleModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
