// lib/features/donors/models/donor_model.dart

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'donor_model.g.dart';

@JsonSerializable()
class DonorModel {
  @JsonKey(name: 'DId')
  final int dId;

  @JsonKey(name: 'DonorID')
  final String donorId;

  @JsonKey(name: 'PatronID')
  final String? patronId;

  @JsonKey(name: 'DonorName')
  final String donorName;

  @JsonKey(name: 'EmailID')
  final String? emailId;

  @JsonKey(name: 'MobileNumber')
  final String? mobileNumber;

  @JsonKey(name: 'TotalAmountDonated')
  final String? totalAmountDonated;

  @JsonKey(name: 'EnrolledBy')
  final String? enrolledBy;

  @JsonKey(name: 'DonorType')
  final int? donorType;

  const DonorModel({
    required this.dId,
    required this.donorId,
    this.patronId,
    required this.donorName,
    this.emailId,
    this.mobileNumber,
    this.totalAmountDonated,
    this.enrolledBy,
    this.donorType,
  });

  /// Display ID: show PatronID if available, otherwise DonorID
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get displayId => (patronId != null && patronId!.isNotEmpty) ? patronId! : donorId;

  /// Formatted total amount with ₹ symbol
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get formattedAmount {
    if (totalAmountDonated == null || totalAmountDonated!.isEmpty || totalAmountDonated == '0') {
      return '₹0';
    }
    return '₹$totalAmountDonated';
  }

  factory DonorModel.fromJson(Map<String, dynamic> json) => _$DonorModelFromJson(json);

  Map<String, dynamic> toJson() => _$DonorModelToJson(this);
}

class DonorSearchResponse {
  final List<DonorModel> donors;
  final int totalRecordsCount;

  const DonorSearchResponse({required this.donors, required this.totalRecordsCount});

  factory DonorSearchResponse.fromJson(Map<String, dynamic> json) {
    final reportDataString = json['reportData'] as String? ?? '[]';
    final List<dynamic> reportDataList = jsonDecode(reportDataString) as List<dynamic>;
    final donors = reportDataList.map((item) => DonorModel.fromJson(item as Map<String, dynamic>)).toList();

    return DonorSearchResponse(donors: donors, totalRecordsCount: (json['totalRecordsCount'] as num?)?.toInt() ?? 0);
  }
}
