// lib/features/admin/devotees/presentation/pages/devotees_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/admin/devotees/domain/entities/devotee_entity.dart';
import 'package:surabhi/injector.dart' as di;

class DevoteesPage extends StatefulWidget {
  const DevoteesPage({super.key});

  @override
  State<DevoteesPage> createState() => _DevoteesPageState();
}

class _DevoteesPageState extends State<DevoteesPage> {
  late Future<List<DevoteeEntity>> _devoteesFuture;

  @override
  void initState() {
    super.initState();
    _devoteesFuture = _fetchDevotees();
  }

  Future<List<DevoteeEntity>> _fetchDevotees() async {
    final api = di.sl<ApiClient>();
    final response = await api.dio.get(ApiConstants.devoteeListPath);

    List<dynamic> devoteesList;
    if (response.data is List) {
      devoteesList = response.data as List<dynamic>;
    } else if (response.data is Map && response.data['devotees'] != null) {
      devoteesList = response.data['devotees'] as List<dynamic>;
    } else {
      devoteesList = [];
    }

    return devoteesList.map((devotee) => DevoteeEntity.fromJson(devotee as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DevoteeEntity>>(
      future: _devoteesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final devotees = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devotees.length,
            itemBuilder: (context, index) => _buildDevoteeCard(devotees[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDevoteeCard(DevoteeEntity devotee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left side: Round Avatar
            _buildAvatar(devotee),
            const SizedBox(width: 12),
            // Right side: 3 lines (Name, Email, Mobile)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name (bold, higher font)
                  Text(
                    devotee.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Email (small)
                  Text(
                    devotee.email,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Mobile (small)
                  Text(
                    devotee.mobileNumber,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(DevoteeEntity devotee) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor.withValues(alpha: 0.2)),
      child: devotee.avatar != null && devotee.avatarContentType != null
          ? ClipOval(child: Image.memory(base64Decode(devotee.avatar!), fit: BoxFit.cover))
          : Center(
              child: Text(
                devotee.name.isNotEmpty ? devotee.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
