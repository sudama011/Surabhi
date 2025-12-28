import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/utils/string_extensions.dart';
import 'package:surabhi/features/admin/users/models/registered_user_model.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        // If users list is not loaded yet, trigger load and show loader
        if (state.status == UsersStatus.initial || (state.status == UsersStatus.error && state.users.isEmpty)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UsersBloc>().add(const GetUsersEvent());
          });

          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state.status == UsersStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Find the user in the loaded users list
        RegisteredUserModel? user;
        if (state.status == UsersStatus.loaded && state.users.isNotEmpty) {
          try {
            user = state.users.firstWhere((u) => u.id.toString() == userId);
          } catch (e) {
            // User not found in list
          }
        }

        if (user == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }

        return _buildUserDetailsView(context, theme, user, state);
      },
    );
  }

  Widget _buildUserDetailsView(BuildContext context, ThemeData theme, RegisteredUserModel user, UsersState state) {
    return BlocListener<UsersBloc, UsersState>(
      listenWhen: (previous, current) => previous.adminOpStatus != current.adminOpStatus,
      listener: (context, blockState) {
        if (blockState.adminOpStatus == AdminOpStatus.success) {
          UiUtils.showSnackBar(
            context,
            blockState.adminOpMessage ?? 'Operation successful',
            backgroundColor: AppColors.successColor,
          );

          if (context.canPop()) {
            context.pop(); // Go back to list on success (e.g. after delete)
          }
        } else if (blockState.adminOpStatus == AdminOpStatus.failure) {
          UiUtils.showSnackBar(
            context,
            blockState.adminOpMessage ?? 'Operation failed',
            backgroundColor: AppColors.errorColor,
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context, theme, user),
            const SizedBox(height: 24),
            _buildInfoCard(context, 'Personal Information', [
              _buildInfoRow('Email', user.email),
              _buildInfoRow('Mobile', user.mobileNumber),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard(context, 'Account Information', [
              _buildInfoRow('User ID', user.id.toString()),
              _buildInfoRow('Role', user.role.name.toUpperCase()),
            ]),
            const SizedBox(height: 24),
            _buildActionButtons(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, ThemeData theme, RegisteredUserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryColor,
              child: Text(
                user.avatarInitial,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: .7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Text(
                      user.role.name.toUpperCase(),
                      style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildActionButtons(BuildContext context, RegisteredUserModel user) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showChangeRoleDialog(context, user),
            icon: const Icon(Icons.security),
            label: const Text('Change Role'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showEditPasswordDialog(context, user),
            icon: const Icon(Icons.lock_reset),
            label: const Text('Reset Password'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showRemoveUserDialog(context, user),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove User'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  void _showChangeRoleDialog(BuildContext context, RegisteredUserModel user) {
    // Capture bloc before showing dialog
    final usersBloc = context.read<UsersBloc>();
    Role selectedRole = user.role;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Role'),
              content: DropdownButtonFormField<Role>(
                value: selectedRole,
                items: Role.values
                    .map((role) => DropdownMenuItem(value: role, child: Text(role.name.toCapitalized)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedRole = value);
                },
                decoration: const InputDecoration(labelText: 'Select new role'),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (selectedRole == user.role) {
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

  void _showEditPasswordDialog(BuildContext context, RegisteredUserModel user) {
    final usersBloc = context.read<UsersBloc>();
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Min 6 characters',
                prefixIcon: Icon(Icons.key),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 6) {
                  return 'Min 6 characters required';
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
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveUserDialog(BuildContext context, RegisteredUserModel user) {
    final usersBloc = context.read<UsersBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Are you sure you want to remove ${user.email}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              usersBloc.add(RemoveUserEvent(email: user.email));
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
