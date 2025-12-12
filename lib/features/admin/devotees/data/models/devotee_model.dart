// lib/features/admin/devotees/data/models/devotee_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:surabhi/features/admin/devotees/domain/entities/devotee_entity.dart';

part 'devotee_model.g.dart';

@JsonSerializable()
class DevoteeModel extends DevoteeEntity {
  DevoteeModel({
    required super.id,
    required super.name,
    required super.code,
    required super.mobileNumber,
    required super.email,
    super.avatar,
    super.avatarContentType,
  });

  factory DevoteeModel.fromJson(Map<String, dynamic> json) => _$DevoteeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DevoteeModelToJson(this);
}
