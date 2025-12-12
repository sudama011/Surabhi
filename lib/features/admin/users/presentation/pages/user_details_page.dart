// lib/features/admin/users/presentation/pages/user_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/role_constants.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/features/admin/users/domain/entities/register_user_entity.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart';

class UserDetailsPage extends StatelessWidget {
  final RegisterUserEntity user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is AdminOperationSuccess) {
          UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.successColor);

          // Refresh users list so changes reflect when we go back
          context.read<UsersBloc>().add(const GetUsersEvent());

          if (context.canPop()) {
            context.pop();
          }
        } else if (state is AdminOperationError) {
          UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar and Basic Info
              _buildUserHeader(context, theme),

              const SizedBox(height: 24),

              // User Information Cards
              _buildInfoCard(context, 'Personal Information', [
                _buildInfoRow('Name', 'Not provided'),
                _buildInfoRow('Email', user.email),
                _buildInfoRow('Mobile', user.mobileNumber ?? 'Not provided'),
              ]),

              const SizedBox(height: 16),

              _buildInfoCard(context, 'Account Information', [
                _buildInfoRow('User ID', user.email),
                _buildInfoRow('Role', user.role.toUpperCase()),
              ]),

              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryColor,
              child: Text(
                user.avatarInitial,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            const SizedBox(width: 20),

            // Basic Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getRoleColor(user.role)),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(color: _getRoleColor(user.role), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        // Change Role Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showChangeRoleDialog(context),
            icon: const Icon(Icons.security),
            label: const Text('Change Role'),
          ),
        ),
        // Edit Password Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showEditPasswordDialog(context),
            icon: const Icon(Icons.lock),
            label: const Text('Edit Password'),
          ),
        ),
        // Remove User Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showRemoveUserDialog(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove User'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Back Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (context.mounted) {
                context.pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to List'),
          ),
        ),
      ],
    );
  }

  void _showChangeRoleDialog(BuildContext context) {
    final usersBloc = context.read<UsersBloc>();
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Role'),
              content: DropdownButtonFormField<String>(
                value: selectedRole,
                items: RoleConstants.roles
                    .map(
                      (role) =>
                          DropdownMenuItem<String>(value: role, child: Text(RoleConstants.getRoleDisplayName(role))),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Select new role'),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (selectedRole.isEmpty || selectedRole == user.role) {
                      Navigator.pop(dialogContext);
                      return;
                    }

                    Navigator.pop(dialogContext);
                    usersBloc.add(ChangeUserRoleEvent(email: user.email, newRole: selectedRole));
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditPasswordDialog(BuildContext context) {
    final usersBloc = context.read<UsersBloc>();
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Password'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password', hintText: 'Min 6 characters'),
              validator: (value) {
                if (value == null || value.trim().length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final newPassword = passwordController.text.trim();
                Navigator.pop(dialogContext);
                usersBloc.add(ResetUserPasswordEvent(email: user.email, newPassword: newPassword));
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveUserDialog(BuildContext context) {
    final usersBloc = context.read<UsersBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Are you sure you want to remove ${user.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              usersBloc.add(RemoveUserEvent(email: user.email));
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    return AppColors.getRoleColor(role);
  }
}
