// lib/features/admin/users/presentation/pages/create_user_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/utils/validators.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/features/admin/roles/domain/entities/role_entity.dart';
import 'package:surabhi/injector.dart' as di;

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
  bool _isLoading = false;
  List<RoleEntity> _roles = [];
  bool _rolesLoading = true;
  String? _rolesError;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final api = di.sl<ApiClient>();
      final response = await api.dio.get(ApiConstants.userRolesPath);

      List<dynamic> rolesList;
      if (response.data is List) {
        rolesList = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['roles'] != null) {
        rolesList = response.data['roles'] as List<dynamic>;
      } else {
        rolesList = [];
      }

      if (mounted) {
        setState(() {
          _roles = rolesList.map((role) => RoleEntity.fromJson(role as Map<String, dynamic>)).toList();
          _rolesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rolesError = 'Failed to load roles: $e';
          _rolesLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading || _role == null) return; // Prevent double submission

    setState(() => _isLoading = true);

    final api = di.sl<ApiClient>();
    try {
      final body = json.encode({
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'role': _role,
      });
      await api.dio.post(ApiConstants.registerPath, data: body);
      if (!mounted) return;
      UiUtils.showSnackBar(context, 'User created successfully', backgroundColor: AppColors.successColor);
      if (context.mounted) context.pop();
    } catch (e) {
      if (mounted) {
        UiUtils.showSnackBar(context, 'Failed to create user: $e', backgroundColor: AppColors.errorColor);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
            if (_rolesLoading)
              const Center(child: CircularProgressIndicator())
            else if (_rolesError != null)
              Text('Error: $_rolesError', style: const TextStyle(color: Colors.red))
            else
              DropdownButtonFormField<String>(
                value: _role,
                items: _roles.map((role) => DropdownMenuItem(value: role.id, child: Text(role.name))).toList(),
                onChanged: (v) => setState(() => _role = v),
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (v) => v == null ? 'Please select a role' : null,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}
