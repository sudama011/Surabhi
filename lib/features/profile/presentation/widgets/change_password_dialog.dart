import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/utils/validators.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePasswordRequested(oldPassword: _oldPassCtrl.text, newPassword: _newPassCtrl.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to Bloc State to close dialog on success or show error
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfilePasswordChangeSuccess) {
          context.pop(); // Close dialog
          UiUtils.showSnackBar(context, 'Password changed successfully', backgroundColor: AppColors.successColor);
        } else if (state is ProfilePasswordChangeFailure) {
          UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
        }
      },
      child: AlertDialog(
        title: const Text('Change Password'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _oldPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.vpn_key)),
                    validator: AppValidators.passwordValidator,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: Icon(Icons.check_circle_outline),
                    ),
                    validator: (val) {
                      if (val != _newPassCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const CircularProgressIndicator();
              }
              return ElevatedButton(onPressed: _submit, child: const Text('Change'));
            },
          ),
        ],
      ),
    );
  }
}
