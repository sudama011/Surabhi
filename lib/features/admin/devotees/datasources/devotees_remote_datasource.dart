// lib/features/admin/devotees/data/datasources/devotees_remote_datasource.dart

import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/features/admin/devotees/models/devotee_model.dart';

abstract class DevoteesRemoteDataSource {
  Future<List<DevoteeModel>> getDevotees();
}

class DevoteesRemoteDataSourceImpl implements DevoteesRemoteDataSource {
  final ApiClient apiClient;

  DevoteesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<DevoteeModel>> getDevotees() async {
    final response = await apiClient.get(ApiConstants.devoteeListPath);

    // Handle both array and map response formats
    List<dynamic> devoteesList;
    if (response is List) {
      devoteesList = response;
    } else if (response is Map && response['devotees'] != null) {
      devoteesList = response['devotees'] as List<dynamic>;
    } else {
      devoteesList = [];
    }

    return devoteesList.map((devotee) => DevoteeModel.fromJson(devotee as Map<String, dynamic>)).toList();
  }
}
