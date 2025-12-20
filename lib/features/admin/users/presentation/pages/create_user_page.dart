// lib/features/admin/users/presentation/pages/create_user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/utils/validators.dart';
import 'package:surabhi/core/utils/string_extensions.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  Role? _selectedRole;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      UiUtils.showSnackBar(context, 'Please select a role', backgroundColor: AppColors.errorColor);
      return;
    }

    context.read<UsersBloc>().add(
      CreateUserRequested(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        role: _selectedRole!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      listenWhen: (previous, current) => previous.adminOpStatus != current.adminOpStatus,
      listener: (context, state) {
        if (state.adminOpStatus == AdminOpStatus.success) {
          UiUtils.showSnackBar(context, 'User created successfully', backgroundColor: AppColors.successColor);
          context.pop(); // Go back to list
        } else if (state.adminOpStatus == AdminOpStatus.failure) {
          UiUtils.showSnackBar(
            context,
            state.adminOpMessage ?? 'Creation failed',
            backgroundColor: AppColors.errorColor,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Responsive constraint
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.emailValidator,
                    onChanged: (value) {
                      final lowercaseValue = value.toLowerCase();
                      if (value != lowercaseValue) {
                        _emailController.value = _emailController.value.copyWith(
                          text: lowercaseValue,
                          selection: TextSelection.collapsed(offset: lowercaseValue.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: AppValidators.passwordValidator,
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.phoneValidator,
                  ),
                  const SizedBox(height: 16),

                  // Role Dropdown
                  DropdownButtonFormField<Role>(
                    value: _selectedRole,
                    items: Role.values
                        .map((role) => DropdownMenuItem(value: role, child: Text(role.name.toCapitalized)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRole = v),
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                    ),
                    validator: (v) => v == null ? 'Please select a role' : null,
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  BlocBuilder<UsersBloc, UsersState>(
                    builder: (context, state) {
                      final isLoading = state.adminOpStatus == AdminOpStatus.loading;

                      return ElevatedButton(
                        onPressed: isLoading ? null : () => _submit(context),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Create User'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
