import 'package:flutter/material.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/theme/app_colors.dart';

class UserDetailsSection extends StatelessWidget {
  final UserModel user;

  const UserDetailsSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailCard(context, label: 'Name', value: user.name ?? 'Not provided', icon: Icons.person),
          const SizedBox(height: 12),
          _buildDetailCard(context, label: 'Code', value: user.code ?? 'Not provided', icon: Icons.person),
          const SizedBox(height: 12),
          _buildDetailCard(context, label: 'Email', value: user.email, icon: Icons.email),
          const SizedBox(height: 12),
          _buildDetailCard(
            context,
            label: 'Mobile Number',
            value: user.mobileNumber ?? 'Not provided',
            icon: Icons.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
