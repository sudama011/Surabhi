// lib/core/widgets/user_card.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/admin/users/models/registered_user_model.dart';

class UserCard extends StatelessWidget {
  final RegisteredUserModel user;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showRole;
  final bool showSecurityIcon;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.trailing,
    this.showRole = true,
    this.showSecurityIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            user.email.isNotEmpty ? user.email[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.email, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            if (showRole) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getRoleColor(user.role).withValues(alpha: 0.3)),
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: TextStyle(color: _getRoleColor(user.role), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Color _getRoleColor(Role role) {
    return AppColors.getRoleColor(role);
  }
}
