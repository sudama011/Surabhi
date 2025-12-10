// lib/features/auth/data/models/user_profile_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

/// Matches API schema: UserProfile
/// Response from POST /api/Account/profile
@JsonSerializable()
class UserProfileModel {
  @JsonKey(name: 'id')
  final String userId;

  @JsonKey(name: 'userName')
  final String email;

  @JsonKey(name: 'firstName')
  final String? firstName;

  @JsonKey(name: 'lastName')
  final String? lastName;

  @JsonKey(name: 'phoneNumber')
  final String? phoneNumber;

  final String? image;

  @JsonKey(name: 'emailVerified')
  final bool? emailVerified;

  @JsonKey(name: 'phoneVerified')
  final bool? phoneVerified;

  UserProfileModel({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.image,
    this.emailVerified,
    this.phoneVerified,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);
}
