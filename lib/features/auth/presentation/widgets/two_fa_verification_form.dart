// lib/features/auth/presentation/widgets/two_fa_verification_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/features/auth/models/twofa_provider_model.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class TwoFAVerificationForm extends StatefulWidget {
  final TwoFAProvider provider;
  final VoidCallback onBack;

  const TwoFAVerificationForm({super.key, required this.provider, required this.onBack});

  @override
  State<TwoFAVerificationForm> createState() => _TwoFAVerificationFormState();
}

class _TwoFAVerificationFormState extends State<TwoFAVerificationForm> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());

  void _verify() {
    final otp = _controllers.map((e) => e.text).join();
    if (otp.length == 6) {
      context.read<AuthBloc>().add(OTPVerificationRequested(otp: otp));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.security, size: 60, color: Colors.blue),
        const SizedBox(height: 16),
        Text(
          'Verify it\'s you', 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the code sent to ${widget.provider.type}:', 
          style: TextStyle(color: Colors.grey[600])
        ),
        Text(
          widget.provider.maskedValue,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildDigitInput(index)),
        ),

        const SizedBox(height: 24),

        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Auth2FALoading) return const CircularProgressIndicator();
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _verify, child: const Text('Verify')),
            );
          },
        ),
        TextButton(onPressed: widget.onBack, child: const Text('Back')),
      ],
    );
  }

  Widget _buildDigitInput(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
          if (val.isEmpty && index > 0) FocusScope.of(context).previousFocus();
        },
      ),
    );
  }
}
