// lib/features/admin/devotees/data/datasources/devotees_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/utils/error_utils.dart';
import 'package:surabhi/features/admin/devotees/data/models/devotee_model.dart';

abstract class DevoteesRemoteDataSource {
  Future<List<DevoteeModel>> getDevotees();
}

class DevoteesRemoteDataSourceImpl implements DevoteesRemoteDataSource {
  final ApiClient apiClient;

  DevoteesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DevoteeModel>> getDevotees() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.devoteeListPath);

      // Handle both array and map response formats
      List<dynamic> devoteesList;
      if (response.data is List) {
        devoteesList = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['devotees'] != null) {
        devoteesList = response.data['devotees'] as List<dynamic>;
      } else {
        devoteesList = [];
      }

      return devoteesList.map((devotee) => DevoteeModel.fromJson(devotee as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to fetch devotees');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }
}
