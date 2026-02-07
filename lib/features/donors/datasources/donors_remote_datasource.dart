// lib/features/donors/datasources/donors_remote_datasource.dart

import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/features/donors/models/donor_model.dart';

abstract class DonorsRemoteDataSource {
  Future<DonorSearchResponse> searchDonors({
    required int pageNumber,
    required int pageSize,
    String? searchText,
    bool isPatron = false,
  });
}

class DonorsRemoteDataSourceImpl implements DonorsRemoteDataSource {
  final ApiClient apiClient;

  DonorsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DonorSearchResponse> searchDonors({
    required int pageNumber,
    required int pageSize,
    String? searchText,
    bool isPatron = false,
  }) async {
    final body = <String, dynamic>{'pageNumber': pageNumber, 'pageSize': pageSize, 'isPatron': isPatron};

    if (searchText != null && searchText.isNotEmpty) {
      body['searchText'] = searchText;
    }

    final response = await apiClient.post(ApiConstants.donorSearchPath, data: body);

    if (response is Map<String, dynamic>) {
      return DonorSearchResponse.fromJson(response);
    }

    return const DonorSearchResponse(donors: [], totalRecordsCount: 0);
  }
}
