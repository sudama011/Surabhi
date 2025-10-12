// lib/features/auth/presentation/pages/twofa_verify_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/app_text_field.dart';
import 'package:surabhi/core/widgets/error_display.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class TwoFAVerifyPage extends StatefulWidget {
  const TwoFAVerifyPage({super.key});

  @override
  State<TwoFAVerifyPage> createState() => _TwoFAVerifyPageState();
}

class _TwoFAVerifyPageState extends State<TwoFAVerifyPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP(String method) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(OTPVerificationRequested(otp: _otpController.text.trim(), method: method));
    }
  }

  @override
  Widget build(BuildContext context) {
    final method = GoRouterState.of(context).uri.queryParameters['method'] ?? 'email';

    return AppScaffold(
      title: 'Verify OTP',
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Successfully authenticated - router will handle navigation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('2FA verification successful!'), backgroundColor: AppColors.successColor),
            );
          } else if (state is Auth2FAError) {
            // Show error message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.errorColor));
          }
        },
        builder: (context, state) {
          final isLoading = state is Auth2FALoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.verified_user, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Verify Your Identity',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the verification code sent to your ${method == 'email' ? 'email' : 'phone'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (state is Auth2FAOTPSent)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.successColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.successColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(state.message, style: TextStyle(color: AppColors.successColor)),
                          ),
                        ],
                      ),
                    ),
                  AppTextField(
                    controller: _otpController,
                    labelText: 'Enter OTP',
                    hintText: '123456',
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.trim().length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (state is Auth2FAError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ErrorDisplay(message: state.message),
                    ),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _verifyOTP(method),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Verify OTP'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.go('/2fa/choice');
                          },
                    child: const Text('Resend OTP'),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(height: 24),
                  // Mock OTP hint for testing
                  if (state is Auth2FAOTPSent)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.infoColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: AppColors.infoColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Testing Mode',
                                style: TextStyle(color: AppColors.infoColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'For testing, use OTP: 123456',
                            style: TextStyle(color: AppColors.infoColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
