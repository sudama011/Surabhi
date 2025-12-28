// lib/features/admin/devotees/models/devotee_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'devotee_model.g.dart';

@JsonSerializable()
class DevoteeModel {
  final int? id;
  final String? name;
  final String? code;
  final String? mobileNumber;
  final String email;
  final String? avatar;
  final String? avatarContentType;

  DevoteeModel({
    this.id,
    this.name,
    this.code,
    this.mobileNumber,
    required this.email,
    this.avatar,
    this.avatarContentType,
  });
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get avatarInitial => name != null && name!.isNotEmpty
      ? name![0].toUpperCase()
      : email.isNotEmpty
      ? email[0].toUpperCase()
      : '?';

  factory DevoteeModel.fromJson(Map<String, dynamic> json) => _$DevoteeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DevoteeModelToJson(this);
}
