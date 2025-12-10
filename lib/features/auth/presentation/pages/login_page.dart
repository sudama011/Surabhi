// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/services/security_service.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/utils/validators.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/injector.dart' as di;
import 'package:surabhi/routes/app_navigator.dart';

class LoginPage extends StatefulWidget {
  final bool checkAuthOnInit;

  const LoginPage({super.key, this.checkAuthOnInit = true});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();
  late bool _showAuthCheck;

  // Auth flow states
  bool _showLoginForm = false;
  bool _show2FAChoice = false;
  bool _show2FAVerify = false;
  String _selectedTwoFAMethod = 'email';
  bool _biometricAttempted = false;

  String get _timeBasedGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  void initState() {
    super.initState();
    _showAuthCheck = widget.checkAuthOnInit;

    if (_showAuthCheck) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BlocProvider.of<AuthBloc>(context).add(AppStarted());
      });
    } else {
      _initializeBiometric();
    }
  }

  Future<void> _initializeBiometric() async {
    if (kIsWeb) {
      setState(() => _showLoginForm = true);
      return;
    }

    try {
      final securityService = di.sl<SecurityService>();
      final method = await securityService.getAvailableMethod();

      if (method == SecurityMethod.biometric) {
        // Auto-trigger biometric on first load
        _attemptBiometricAuth();
      } else {
        setState(() => _showLoginForm = true);
      }
    } catch (e) {
      setState(() => _showLoginForm = true);
    }
  }

  Future<void> _attemptBiometricAuth() async {
    if (_biometricAttempted) return;

    setState(() => _biometricAttempted = true);

    try {
      final securityService = di.sl<SecurityService>();
      final authenticated = await securityService.authenticateBiometric();

      if (authenticated) {
        // Biometric successful - proceed with login
        // For now, show login form (in real app, you'd have stored credentials)
        setState(() => _showLoginForm = true);
      } else {
        // User cancelled biometric - show login form
        setState(() => _showLoginForm = true);
      }
    } catch (e) {
      setState(() => _showLoginForm = true);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        LoginRequested(email: _emailController.text.trim().toLowerCase(), password: _passwordController.text.trim()),
      );
    }
  }

  void _resetForm() {
    _emailController.clear();
    _passwordController.clear();
    _formKey.currentState?.reset();
  }

  void _sendOTP() {
    context.read<AuthBloc>().add(TwoFAMethodSelected(method: _selectedTwoFAMethod));
  }

  void _verifyOTP() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      context.read<AuthBloc>().add(OTPVerificationRequested(otp: otp, method: _selectedTwoFAMethod));
    } else {
      UiUtils.showSnackBar(context, 'Please enter all 6 digits', backgroundColor: AppColors.errorColor);
    }
  }

  void _backToLoginForm() {
    setState(() {
      _show2FAChoice = false;
      _show2FAVerify = false;
      _selectedTwoFAMethod = 'email';
      for (var controller in _otpControllers) {
        controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppNavigator.navigateBasedOnRole(context, state.user.role);
          } else if (state is Auth2FARequired) {
            setState(() {
              _show2FAChoice = true;
              _showLoginForm = false;
            });
          } else if (state is Auth2FAOTPSent) {
            setState(() {
              _show2FAVerify = true;
              _show2FAChoice = false;
            });
          } else if (state is AuthUnauthenticated) {
            setState(() => _showAuthCheck = false);
          } else if (state is AuthError) {
            UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
          } else if (state is Auth2FAError) {
            UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Welcome to ${AppConstants.appName}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        if (_showAuthCheck)
                          _buildAuthCheckWidget()
                        else if (_show2FAChoice)
                          _build2FAChoiceWidget()
                        else if (_show2FAVerify)
                          _build2FAVerifyWidget()
                        else
                          _buildLoginWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isKeyboardOpen && _showLoginForm) _buildEventsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCheckWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('Checking authentication status...', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildLoginWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _timeBasedGreeting,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.lightTextColor),
        ),
        const SizedBox(height: 8),
        Text('Sign in to continue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        const SizedBox(height: 30),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: AppValidators.emailValidator,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: AppValidators.passwordValidator,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Forgot password?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 10),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _resetForm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('RESET'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _build2FAChoiceWidget() {
    return Column(
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Card(
          child: RadioListTile<String>(
            title: const Text('Email'),
            subtitle: const Text('Receive OTP via email'),
            value: 'email',
            groupValue: _selectedTwoFAMethod,
            onChanged: (v) => setState(() => _selectedTwoFAMethod = v ?? 'email'),
            secondary: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: RadioListTile<String>(
            title: const Text('Phone'),
            subtitle: const Text('Receive OTP via SMS'),
            value: 'phone',
            groupValue: _selectedTwoFAMethod,
            onChanged: (v) => setState(() => _selectedTwoFAMethod = v ?? 'phone'),
            secondary: const Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 32),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is Auth2FALoading;
            return ElevatedButton(
              onPressed: isLoading ? null : _sendOTP,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send OTP'),
            );
          },
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: () => _backToLoginForm(), child: const Text('Back to Login')),
      ],
    );
  }

  Widget _build2FAVerifyWidget() {
    return Column(
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
          'Enter the verification code sent to your ${_selectedTwoFAMethod == 'email' ? 'email' : 'phone'}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildOTPInputFields(),
        const SizedBox(height: 24),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is Auth2FALoading;
            return ElevatedButton(
              onPressed: isLoading ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Verify OTP'),
            );
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() {
            _show2FAVerify = false;
            _show2FAChoice = true;
            for (var controller in _otpControllers) {
              controller.clear();
            }
          }),
          child: const Text('Resend OTP'),
        ),
        TextButton(onPressed: () => _backToLoginForm(), child: const Text('Back to Login')),
      ],
    );
  }

  Widget _buildOTPInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 50,
          child: TextFormField(
            controller: _otpControllers[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Container(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Upcoming Events',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.lightTextColor),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2)),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temple Event ${index + 1}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          'Join us for the grand celebration and kirtan.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
