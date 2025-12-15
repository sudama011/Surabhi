// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/features/auth/models/twofa_provider_model.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/auth/presentation/widgets/auth_page_layout.dart'; // Import layout
import 'package:surabhi/features/auth/presentation/widgets/login_form.dart';
import 'package:surabhi/features/auth/presentation/widgets/two_fa_selection_form.dart';
import 'package:surabhi/features/auth/presentation/widgets/two_fa_verification_form.dart';
import 'package:surabhi/routes/app_navigator.dart';

class LoginPage extends StatefulWidget {
  final bool checkAuthOnInit;
  const LoginPage({super.key, this.checkAuthOnInit = true});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isCheckingAuth = true;
  List<TwoFAProvider> _availableProviders = [];
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _isCheckingAuth = widget.checkAuthOnInit;

    if (_isCheckingAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthBloc>().add(AppStarted());
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
            AppNavigator.navigateBasedOnRole(context, state.user.role);
          } else if (state is Auth2FARequired) {
            setState(() {
              _isCheckingAuth = false;
              _availableProviders = state.providers;
            });
          } else if (state is Auth2FAOTPSent) {
            setState(() => _selectedMethod = state.provider.type);
          } else if (state is AuthUnauthenticated) {
            setState(() => _isCheckingAuth = false);
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
    if (state is Auth2FARequired || (state is Auth2FALoading && _selectedMethod == null)) {
      return TwoFASelectionForm(
        providers: _availableProviders,
        onBack: () => context.read<AuthBloc>().add(LogoutRequested()),
      );
    }

    if (state is Auth2FAOTPSent || (state is Auth2FALoading && _selectedMethod != null)) {
      return TwoFAVerificationForm(
        method: _selectedMethod ?? 'Method',
        onBack: () => context.read<AuthBloc>().add(LogoutRequested()),
      );
    }

    return const LoginForm();
  }
}
