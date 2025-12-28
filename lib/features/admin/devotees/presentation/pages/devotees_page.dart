// lib/features/admin/devotees/presentation/pages/devotees_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/admin/devotees/models/devotee_model.dart';
import 'package:surabhi/features/admin/devotees/presentation/bloc/devotees_bloc.dart';

class DevoteesPage extends StatelessWidget {
  const DevoteesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevoteesBloc, DevoteesState>(
      builder: (context, state) {
        if (state is DevoteesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DevoteesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<DevoteesBloc>().add(const GetDevoteesEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is DevoteesLoaded) {
          final devotees = state.devotees;
          if (devotees.isEmpty) {
            return const Center(child: Text('No devotees found'));
          }
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

  Widget _buildDevoteeCard(DevoteeModel devotee) {
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
                    devotee.name ?? 'Unknown',
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
                    devotee.mobileNumber ?? 'N/A',
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

  Widget _buildAvatar(DevoteeModel devotee) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor.withValues(alpha: 0.2)),
      child: devotee.avatar != null && devotee.avatarContentType != null
          ? ClipOval(child: Image.memory(base64Decode(devotee.avatar!), fit: BoxFit.cover))
          : Center(
              child: Text(devotee.avatarInitial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
    );
  }
}
