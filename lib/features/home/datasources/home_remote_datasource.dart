// lib/features/home/datasources/home_remote_datasource.dart

import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/features/home/models/home_summary_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeSummaryModel> getHomeSummary();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HomeSummaryModel> getHomeSummary() async {
    final response = await apiClient.post(ApiConstants.homeSummaryPath);

    // The API returns { "summary": { ... } }
    if (response is Map<String, dynamic> && response.containsKey('summary')) {
      return HomeSummaryModel.fromJson(response['summary'] as Map<String, dynamic>);
    }

    // Fallback: try parsing the response directly
    if (response is Map<String, dynamic>) {
      return HomeSummaryModel.fromJson(response);
    }

    throw Exception('Unexpected response format for home summary');
  }
}
