// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/features/auth/models/twofa_provider_model.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/auth/presentation/widgets/auth_page_layout.dart';
import 'package:surabhi/features/auth/presentation/widgets/login_form.dart';
import 'package:surabhi/features/auth/presentation/widgets/two_fa_selection_form.dart';
import 'package:surabhi/features/auth/presentation/widgets/two_fa_verification_form.dart';

class LoginPage extends StatefulWidget {
  final bool checkAuthOnInit;
  const LoginPage({super.key, this.checkAuthOnInit = true});

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
    _isCheckingAuth = widget.checkAuthOnInit;

    if (_isCheckingAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AuthBloc>().add(AppStarted());
        }
      });
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
          }
        },
        // Use the Wrapper Widget here!
        child: AuthPageLayout(child: _isCheckingAuth ? _buildLoadingState() : _buildDynamicContent()),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Column(children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Verifying session...')]);
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
    // Show this if a method is selected AND (OTP Sent OR Loading OR *Error*)
    if (_selectedProvider != null) {
      if (state is Auth2FAOTPSent || state is Auth2FALoading || state is Auth2FAError) {
        return TwoFAVerificationForm(
          provider: _selectedProvider!,
          onBack: () {
            if (_availableProviders.length > 1) {
              // Yes: Go back to list selection
              setState(() => _selectedProvider = null);
            } else {
              // No: Only 1 option exists, so 'Back' means Cancel/Logout
              context.read<AuthBloc>().add(LogoutRequested());
            }
          },
        );
      }
    }

    // 2. SELECTION VIEW
    // Show this if 2FA is Required OR (Loading/Error occurred during selection)
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

    // 2. SELECTION VIEW
    // Show this if we have providers loaded, but no specific provider is selected yet.
    // We check `state is! AuthUnauthenticated` to prevent it from showing briefly during logout.
    if (_availableProviders.isNotEmpty && _selectedProvider == null && state is! AuthUnauthenticated) {
      return TwoFASelectionForm(
        providers: _availableProviders,
        onBack: () => context.read<AuthBloc>().add(LogoutRequested()),
      );
    }

    // 3. DEFAULT: Login Form
    return const LoginForm();
  }
}
