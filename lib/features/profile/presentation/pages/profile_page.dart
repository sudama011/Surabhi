import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:surabhi/features/profile/presentation/widgets/profile_actions_section.dart';
import 'package:surabhi/features/profile/presentation/widgets/profile_header.dart';
import 'package:surabhi/features/profile/presentation/widgets/user_details_section.dart';
import 'package:surabhi/injector.dart' as di;
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => di.sl<ProfileBloc>(), child: const _ProfilePageView());
  }
}

class _ProfilePageView extends StatelessWidget {
  const _ProfilePageView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileAvatarUploadSuccess) {
          UiUtils.showSnackBar(context, 'Avatar updated successfully', backgroundColor: AppColors.successColor);
        } else if (state is ProfileAvatarUploadFailure) {
          UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text('Not authenticated'));
          }

          final user = authState.user;
          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. Header (Avatar + Name)
                ProfileHeader(user: user),

                const SizedBox(height: 24),

                // 2. Details (List of info)
                UserDetailsSection(user: user),

                const SizedBox(height: 24),

                // 3. Actions (Change Pass, Logout)
                const ProfileActionsSection(),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
