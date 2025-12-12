// lib/features/admin/users/presentation/pages/create_user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/utils/validators.dart';
import 'package:surabhi/features/admin/roles/presentation/cubit/roles_cubit.dart';
import 'package:surabhi/features/admin/users/presentation/cubit/create_user_cubit.dart';

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
  String? _role;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_role == null) return;

    context.read<CreateUserCubit>().createUser(
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      role: _role!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateUserCubit, CreateUserState>(
      listener: (context, state) {
        if (state is CreateUserSuccess) {
          UiUtils.showSnackBar(context, 'User created successfully', backgroundColor: AppColors.successColor);
          context.pop();
        } else if (state is CreateUserError) {
          UiUtils.showSnackBar(context, state.message, backgroundColor: AppColors.errorColor);
        }
      },

      // below child should be in center
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.emailValidator,
                  onChanged: (value) {
                    // Auto-convert to lowercase as user types
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
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Min 6 characters',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 chars',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v != null && v.isNotEmpty) ? null : 'Phone number is required',
                ),
                const SizedBox(height: 16),
                BlocBuilder<RolesCubit, RolesState>(
                  builder: (context, state) {
                    if (state is RolesLoading || state is RolesInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RolesError) {
                      return Text('Error: ${state.message}', style: const TextStyle(color: Colors.red));
                    } else if (state is RolesLoaded) {
                      final roles = state.roles;
                      return DropdownButtonFormField<String>(
                        value: _role,
                        items: roles
                            .map((role) => DropdownMenuItem<String>(value: role.name, child: Text(role.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _role = v),
                        decoration: const InputDecoration(labelText: 'Role'),
                        validator: (v) => v == null ? 'Please select a role' : null,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<CreateUserCubit, CreateUserState>(
                  builder: (context, state) {
                    final isLoading = state is CreateUserLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Create User'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
