// lib/features/admin/dashboard/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final firstName = (state is AuthAuthenticated) ? state.user.firstName : 'User';
        return Center(child: Text('Hare Krishna $firstName'));
      },
    );
  }
}
