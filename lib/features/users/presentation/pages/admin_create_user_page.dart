// lib/features/users/presentation/pages/admin_create_user_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:surabhi/core/utils/ui_utils.dart';
import 'package:surabhi/core/utils/validators.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/constants/role_constants.dart';

class AdminCreateUserPage extends StatefulWidget {
  const AdminCreateUserPage({super.key});

  @override
  State<AdminCreateUserPage> createState() => _AdminCreateUserPageState();
}

class _AdminCreateUserPageState extends State<AdminCreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'volunteer';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final api = RepositoryProvider.of<ApiClient>(context);
    try {
      final body = json.encode({
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text.trim(),
        'role': _role,
      });
      await api.dio.post('/users/create', data: body);
      if (!mounted) return;
      UiUtils.showSnackBar(context, 'User created successfully', backgroundColor: Colors.green);
      if (context.mounted) context.pop();
    } catch (e) {
      UiUtils.showSnackBar(context, 'Failed to create user: $e', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create User (Admin)',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: AppValidators.emailValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v != null && v.length >= 8) ? null : 'Min 8 chars',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                items: RoleConstants.roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _role = v ?? 'volunteer'),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Create User')),
            ],
          ),
        ),
      ),
    );
  }
}
