import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/models/navigation_item.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final List<NavigationItem> sideNavigationItems;
  final List<NavigationItem> bottomNavigationitems;
  final Function(String) onNavigationSelected;

  const AppShell({
    super.key,
    required this.child,
    required this.sideNavigationItems,
    required this.bottomNavigationitems,
    required this.onNavigationSelected,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int? _getSelectedIndex(String currentRoute, List<NavigationItem> items) {
    int index = items.indexWhere((item) => currentRoute == item.route);
    if (index == -1) {
      index = items.indexWhere((item) => currentRoute.startsWith(item.route) && item.route != '/');
    }
    return index != -1 ? index : null;
  }

  String _getPageTitle(String currentRoute) {
    final allItems = [...widget.sideNavigationItems, ...widget.bottomNavigationitems];
    for (var item in allItems) {
      if (currentRoute.startsWith(item.route) && item.route != '/') return item.label;
    }
    return AppConstants.appName;
  }

  ImageProvider? _getAvatarImage(UserModel user) {
    if (user.avatar != null && user.avatarContentType != null) {
      try {
        final bytes = base64Decode(user.avatar!);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error loading avatar: $e');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppConstants.tablet;
    final isMobile = width < AppConstants.mobile;

    final String currentRoute = GoRouterState.of(context).uri.path;
    final String pageTitle = _getPageTitle(currentRoute);

    // Merge Lists for Rail
    final List<NavigationItem> railItems = isMobile
        ? []
        : [...widget.sideNavigationItems, ...widget.bottomNavigationitems];

    // Calculate Indices
    final int? drawerIndex = _getSelectedIndex(currentRoute, widget.sideNavigationItems);
    final int? bottomNavIndex = _getSelectedIndex(currentRoute, widget.bottomNavigationitems);
    final int? railIndex = _getSelectedIndex(currentRoute, railItems);

    if (widget.sideNavigationItems.isEmpty && widget.bottomNavigationitems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(pageTitle)),
        body: const Center(child: Text('No navigation items configured')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: false,
        leading: isMobile
            ? Builder(
                builder: (context) =>
                    IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
              )
            : null,
        actions: [
          if (isDesktop)
            Container(
              width: 300,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: SearchBar(
                hintText: 'Search...',
                leading: const Icon(Icons.search),
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),

          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                return Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.secondaryColor,
                      backgroundImage: _getAvatarImage(user),
                      child: _getAvatarImage(user) == null
                          ? Text(
                              user.avatarInitial,
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                );
              }
              return IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/profile'));
            },
          ),
        ],
      ),

      drawer: NavigationDrawer(
        selectedIndex: drawerIndex,
        onDestinationSelected: (index) {
          Navigator.pop(context);
          if (index < widget.sideNavigationItems.length) {
            widget.onNavigationSelected(widget.sideNavigationItems[index].route);
          }
        },
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...widget.sideNavigationItems.map(
            (item) => NavigationDrawerDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon ?? item.icon),
              label: Text(item.label),
            ),
          ),
          const Divider(indent: 28, endIndent: 28),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Dark Mode'),
                value: isDark,
                onChanged: (val) => context.read<ThemeCubit>().toggleTheme(val),
              );
            },
          ),
        ],
      ),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
        children: [
          // FIX: SCROLLABLE NAVIGATION RAIL
          if (!isMobile && railItems.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraint) {
                // Use LayoutBuilder to get the available height
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    // Force the rail to be at least as tall as the screen
                    // This keeps the background color consistent if items are few
                    constraints: BoxConstraints(minHeight: constraint.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        extended: isDesktop,
                        selectedIndex: railIndex,
                        onDestinationSelected: (index) {
                          if (index < railItems.length) {
                            widget.onNavigationSelected(railItems[index].route);
                          }
                        },
                        labelType: isDesktop ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                        destinations: railItems.map((item) {
                          return NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon ?? item.icon),
                            label: Text(item.label),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),

          if (!isMobile && railItems.isNotEmpty) const VerticalDivider(thickness: 1, width: 1),

          Expanded(child: widget.child),
        ],
      ),

      bottomNavigationBar: (isMobile && widget.bottomNavigationitems.isNotEmpty)
          ? NavigationBar(
              selectedIndex: bottomNavIndex ?? 0,
              onDestinationSelected: (index) {
                if (index < widget.bottomNavigationitems.length) {
                  widget.onNavigationSelected(widget.bottomNavigationitems[index].route);
                }
              },
              destinations: widget.bottomNavigationitems.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon ?? item.icon),
                  label: item.label,
                );
              }).toList(),
            )
          : null,
    );
  }
}
