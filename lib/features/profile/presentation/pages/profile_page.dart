// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _getAvatarInitial(UserEntity user) {
    // Priority: firstName + lastName, then userName, then email first char
    if (user.firstName?.isNotEmpty ?? false) {
      if (user.lastName?.isNotEmpty ?? false) {
        return '${user.firstName![0]}${user.lastName![0]}';
      }
      return user.firstName![0];
    }
    return user.userName[0];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Not authenticated'));
        }

        final user = authState.user;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Use GoRouter's pop() method for proper navigation
                if (context.canPop()) {
                  context.pop();
                } else {
                  // Fallback: navigate back to admin dashboard
                  context.go('/admin-dashboard');
                }
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),
                // User Details Section
                _buildUserDetailsSection(context, user),
                const SizedBox(height: 24),
                // Verification Section
                _buildVerificationSection(context, user),
                const SizedBox(height: 24),
                // Logout Button
                _buildLogoutButton(context),
                // Extra space for device buttons (safe area)
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserEntity user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
                child: user.image == null
                    ? Text(
                        _getAvatarInitial(user).toUpperCase(),
                        style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              // Change Profile Picture Button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implement image picker
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Change profile picture - Coming soon')));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User Name
          Text(
            '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 4),
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(20)),
            child: Text(
              user.role.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsSection(BuildContext context, UserEntity user) {
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
          _buildDetailCard(context, label: 'First Name', value: user.firstName ?? 'Not provided', icon: Icons.person),
          const SizedBox(height: 12),
          _buildDetailCard(context, label: 'Last Name', value: user.lastName ?? 'Not provided', icon: Icons.person),
          const SizedBox(height: 12),
          _buildDetailCard(context, label: 'Email', value: user.userName, icon: Icons.email),
          const SizedBox(height: 12),
          _buildDetailCard(
            context,
            label: 'Phone Number',
            value: user.phoneNumber ?? 'Not provided',
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

  Widget _buildVerificationSection(BuildContext context, UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verification', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildVerificationItem(
            context,
            label: 'Email Verification',
            isVerified: true,
            onTap: () {
              // TODO: Implement email verification
            },
          ),
          const SizedBox(height: 12),
          _buildVerificationItem(
            context,
            label: 'Phone Verification',
            isVerified: false,
            onTap: () {
              // TODO: Implement phone verification
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(
    BuildContext context, {
    required String label,
    required bool isVerified,
    required VoidCallback onTap,
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
          Icon(isVerified ? Icons.verified : Icons.pending, color: isVerified ? Colors.green : Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(
                  isVerified ? 'Verified' : 'Not verified',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: isVerified ? Colors.green : Colors.orange),
                ),
              ],
            ),
          ),
          if (!isVerified) TextButton(onPressed: onTap, child: const Text('Verify')),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            _showLogoutConfirmation(context);
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutRequested());
              // Navigate to home with checkAuthOnInit: false to skip auth check
              context.go('/', extra: false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
