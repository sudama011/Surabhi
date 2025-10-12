// lib/features/auth/presentation/pages/twofa_choice_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/error_display.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class TwoFAChoicePage extends StatefulWidget {
  const TwoFAChoicePage({super.key});

  @override
  State<TwoFAChoicePage> createState() => _TwoFAChoicePageState();
}

class _TwoFAChoicePageState extends State<TwoFAChoicePage> {
  String _method = 'email';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Two-Factor Authentication',
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Auth2FAOTPSent) {
            // Navigate to OTP verification page
            context.go('/2fa/verify?method=${state.method}');
          } else if (state is Auth2FAError) {
            // Show error message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.errorColor));
          }
        },
        builder: (context, state) {
          final isLoading = state is Auth2FALoading;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(Icons.security, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Two-Factor Authentication',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose how you\'d like to receive your verification code',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  child: RadioListTile<String>(
                    title: const Text('Email'),
                    subtitle: const Text('Receive OTP via email'),
                    value: 'email',
                    groupValue: _method,
                    onChanged: isLoading ? null : (v) => setState(() => _method = v ?? 'email'),
                    secondary: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: RadioListTile<String>(
                    title: const Text('Phone'),
                    subtitle: const Text('Receive OTP via SMS'),
                    value: 'phone',
                    groupValue: _method,
                    onChanged: isLoading ? null : (v) => setState(() => _method = v ?? 'phone'),
                    secondary: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 32),
                if (state is Auth2FAError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ErrorDisplay(message: state.message),
                  ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(TwoFAMethodSelected(method: _method));
                        },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send OTP'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
