// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/services/biometric_service.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/features/auth/models/twofa_provider_model.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/auth/presentation/widgets/auth_page_layout.dart';
import 'package:surabhi/features/auth/presentation/widgets/login_form.dart';
import 'package:surabhi/features/auth/presentation/widgets/two_fa_selection_form.dart';
import 'package:surabhi/features/auth/presentation/widgets/two_fa_verification_form.dart';
import 'package:surabhi/injector.dart' as di;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isCheckingAuth = true;
  List<TwoFAProvider> _availableProviders = [];
  TwoFAProvider? _selectedProvider;

  @override
  void initState() {
    super.initState();
    _checkBiometricAutoLogin();
    if (_isCheckingAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AuthBloc>().add(AppStarted());
      });
    }
  }

  Future<void> _checkBiometricAutoLogin() async {
    final biometricService = di.sl<BiometricService>();
    final isEnabled = await biometricService.isBiometricEnabled;

    if (!mounted) return;
    final authState = context.read<AuthBloc>().state;

    if (isEnabled && authState is! AuthAuthenticated) {
      context.read<AuthBloc>().add(BiometricLoginRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            UiUtils.showSnackBar(context, 'Login successful', backgroundColor: AppColors.successColor);
          } else if (state is Auth2FARequired) {
            setState(() {
              _isCheckingAuth = false;
              _availableProviders = state.providers;
            });
          } else if (state is Auth2FAOTPSent) {
            setState(() => _selectedProvider = state.provider);
          } else if (state is AuthUnauthenticated) {
            setState(() {
              _isCheckingAuth = false;
              _selectedProvider = null;
              _availableProviders = [];
            });
            if (state.message != null) {
              UiUtils.showSnackBar(context, state.message!, backgroundColor: AppColors.errorColor);
            }
          } else if (state is Auth2FAError) {
            UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
          } else if (state is AuthBiometricFailure) {
            // Handle Biometric Cancel/Error
            UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
          }
        },
        child: AuthPageLayout(child: _isCheckingAuth ? _buildLoadingState() : _buildDynamicContent()),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Verifying session...')],
    );
  }

  Widget _buildDynamicContent() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _getContentForState(state));
      },
    );
  }

  Widget _getContentForState(AuthState state) {
    // 1. VERIFICATION VIEW (Priority)
    if (_selectedProvider != null) {
      if (state is Auth2FAOTPSent || state is Auth2FALoading || state is Auth2FAError) {
        return TwoFAVerificationForm(
          provider: _selectedProvider!,
          onBack: () {
            if (_availableProviders.length > 1) {
              setState(() => _selectedProvider = null);
            } else {
              context.read<AuthBloc>().add(LogoutRequested());
            }
          },
        );
      }
    }

    // 2. SELECTION VIEW
    if (state is Auth2FARequired ||
        (state is Auth2FAError && _selectedProvider == null) ||
        (state is Auth2FALoading && _selectedProvider == null)) {
      if (_availableProviders.isNotEmpty) {
        return TwoFASelectionForm(
          providers: _availableProviders,
          onBack: () => context.read<AuthBloc>().add(LogoutRequested()),
        );
      }
    }

    // 3. BIOMETRIC LOADING
    if (state is AuthBiometricLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fingerprint, size: 64, color: AppColors.primaryColor),
          SizedBox(height: 24),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Authenticating...', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      );
    }

    // 4. DEFAULT: Login Form + Manual Biometric Button
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LoginForm(),

        // ADDED: Manual Biometric Trigger (In case user cancels the auto-popup)
        const SizedBox(height: 20),
        FutureBuilder<bool>(
          future: di.sl<BiometricService>().isBiometricEnabled,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return Column(
                children: [
                  const Text('Or login with', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.fingerprint, size: 48, color: AppColors.primaryColor),
                    onPressed: () => context.read<AuthBloc>().add(BiometricLoginRequested()),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
