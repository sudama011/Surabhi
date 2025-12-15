// lib/features/auth/models/twofa_provider_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'twofa_provider_model.g.dart';

@JsonSerializable()
class TwoFAProvider {
  @JsonKey(name: 'name')
  final String type;

  @JsonKey(name: 'label')
  final String maskedValue;

  TwoFAProvider(this.type, this.maskedValue);

  factory TwoFAProvider.fromJson(Map<String, dynamic> json) => _$TwoFAProviderFromJson(json);
  Map<String, dynamic> toJson() => _$TwoFAProviderToJson(this);
}
