// lib/features/auth/presentation/widgets/two_fa_selection_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/auth/models/twofa_provider_model.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class TwoFASelectionForm extends StatefulWidget {
  final List<TwoFAProvider> providers;
  final VoidCallback onBack;

  const TwoFASelectionForm({super.key, required this.providers, required this.onBack});

  @override
  State<TwoFASelectionForm> createState() => _TwoFASelectionFormState();
}

class _TwoFASelectionFormState extends State<TwoFASelectionForm> {
  TwoFAProvider? _selectedProvider;

  @override
  void initState() {
    super.initState();
    // Default to first option if available
    if (widget.providers.isNotEmpty) {
      _selectedProvider = widget.providers.first;
    }
  }

  void _submit() {
    if (_selectedProvider != null) {
      context.read<AuthBloc>().add(SendOTPRequested(provider: _selectedProvider!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select Verification Method',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose where to send the OTP',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        ...widget.providers.map((provider) => _buildProviderCard(provider)),

        const SizedBox(height: 24),

        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Auth2FALoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ElevatedButton(
              onPressed: _selectedProvider != null ? _submit : null,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Send Code'),
            );
          },
        ),
        TextButton(onPressed: widget.onBack, child: const Text('Back to Login')),
      ],
    );
  }

  Widget _buildProviderCard(TwoFAProvider provider) {
    final isSelected = _selectedProvider!.type == provider.type;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? const BorderSide(color: AppColors.primaryColor, width: 2) : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: provider.type,
        groupValue: _selectedProvider!.type,
        onChanged: (val) {
          if (val != null) {
            try {
              final selected = widget.providers.firstWhere((p) => p.type == val);
              setState(() => _selectedProvider = selected);
            } catch (_) {
              // Provider not found, ignore
            }
          }
        },
        title: Text(provider.type), // e.g. "Email"
        subtitle: Text(provider.maskedValue), // e.g. "a***@gmail.com"
        secondary: Icon(
          provider.type.toLowerCase() == 'email'
              ? Icons.email
              : provider.type.toLowerCase() == 'phone'
              ? Icons.phone_android
              : Icons.security,
          color: isSelected ? AppColors.primaryColor : Colors.grey,
        ),
        activeColor: AppColors.primaryColor,
      ),
    );
  }
}
