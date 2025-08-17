// lib/core/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/role_based_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;

  const AppScaffold({super.key, required this.body, required this.title, this.actions, this.onLeadingPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoleBasedAppBar(
        titleText: title,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon')));
            },
          ),
          ...(actions ?? []),
        ],
        onLeadingPressed: onLeadingPressed,
      ),
      drawer: Drawer(child: _RoleAwareDrawer()),
      body: body,
    );
  }
}

class _RoleAwareDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final bool isAdmin = authState is AuthAuthenticated && authState.user.role == 'admin';
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Colors.blue),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('lib/assets/images/hkmistamp.png', width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => context.go('/home')),
        if (isAdmin)
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Register User'),
            onTap: () => context.push('/admin/create-user'),
          ),
        ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
        SwitchListTile(
          secondary: const Icon(Icons.brightness_6),
          title: const Text('Dark Mode'),
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (isDark) => context.read<ThemeCubit>().toggleTheme(isDark),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            // Close the drawer first
            Navigator.of(context).pop();
            // Show confirmation early
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
            // Dispatch logout; router redirect will navigate to login
            context.read<AuthBloc>().add(LogoutRequested());
          },
        ),
      ],
    );
  }
}
