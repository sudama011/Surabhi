// lib/features/home/models/home_summary_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'home_summary_model.g.dart';

@JsonSerializable()
class QuarterlyDonation {
  final int donationYear;
  final int donationQuarter;
  final String totalAmount;

  const QuarterlyDonation({required this.donationYear, required this.donationQuarter, required this.totalAmount});

  /// Parse the formatted amount string (e.g. "2,39,07,330") to a double
  double get amountValue {
    final cleaned = totalAmount.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Display label like "Q1-2025"
  String get label => 'Q$donationQuarter-$donationYear';

  factory QuarterlyDonation.fromJson(Map<String, dynamic> json) => _$QuarterlyDonationFromJson(json);

  Map<String, dynamic> toJson() => _$QuarterlyDonationToJson(this);
}

@JsonSerializable()
class SourceTypeDonation {
  final String sourceType;
  final String totalAmount;

  const SourceTypeDonation({required this.sourceType, required this.totalAmount});

  /// Parse the formatted amount string to a double
  double get amountValue {
    final cleaned = totalAmount.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  factory SourceTypeDonation.fromJson(Map<String, dynamic> json) => _$SourceTypeDonationFromJson(json);

  Map<String, dynamic> toJson() => _$SourceTypeDonationToJson(this);
}

@JsonSerializable()
class HomeSummaryModel {
  final List<QuarterlyDonation> quarterlyDonations;
  final List<SourceTypeDonation> sourceTypeDonations;
  final String grandTotalAmount;

  const HomeSummaryModel({
    required this.quarterlyDonations,
    required this.sourceTypeDonations,
    required this.grandTotalAmount,
  });

  /// Parse the formatted grand total amount string to a double
  double get grandTotalValue {
    final cleaned = grandTotalAmount.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  factory HomeSummaryModel.fromJson(Map<String, dynamic> json) => _$HomeSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeSummaryModelToJson(this);
}
