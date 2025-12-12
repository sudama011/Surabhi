import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
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
  late String pageTitle;

  @override
  void initState() {
    super.initState();
    pageTitle = 'Surabhi';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePageTitle();
  }

  void _updatePageTitle() {
    final currentRoute = GoRouterState.of(context).uri.path;

    // Check side navigation items
    for (final item in widget.sideNavigationItems) {
      if (currentRoute == item.route) {
        if (pageTitle != item.label) {
          pageTitle = item.label;
        }
        return;
      }
    }

    // Check bottom navigation items
    for (final item in widget.bottomNavigationitems) {
      if (currentRoute == item.route) {
        if (pageTitle != item.label) {
          pageTitle = item.label;
        }
        return;
      }
    }
  }

  String _getAvatarInitial(dynamic user) {
    // Priority: name, then email first char
    if (user.name != null && user.name!.isNotEmpty) {
      return user.name![0];
    }
    return user.userName[0];
  }

  ImageProvider? _getAvatarImage(dynamic user) {
    if (user.avatar != null && user.avatarContentType != null) {
      try {
        final imageData = user.avatar!;
        final bytes = base64Decode(imageData);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error loading avatar: $e');
      }
    }
    return null;
  }

  bool _isRouteSelected(String currentRoute, String itemRoute) {
    // Check if the current route matches the item route
    return currentRoute == itemRoute;
  }

  int _getSelectedBottomNavIndex(String currentRoute) {
    // Find the index of the matching bottom nav item
    for (int i = 0; i < widget.bottomNavigationitems.length; i++) {
      if (currentRoute == widget.bottomNavigationitems[i].route) {
        return i;
      }
    }
    // Return 0 as default if no match found
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppConstants.tablet;
    final isMobile = width < AppConstants.mobile;
    final currentRoute = GoRouterState.of(context).uri.path;

    // Update page title based on current route
    _updatePageTitle();

    // Validate navigation items
    if (widget.sideNavigationItems.isEmpty && widget.bottomNavigationitems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(pageTitle)),
        body: const Center(child: Text('No navigation items configured')),
      );
    }

    return Scaffold(
      // 2. Common Top App Bar
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: false,
        leading: Builder(
          builder: (context) {
            return IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer());
          },
        ),
        actions: [
          // Search Bar (Expanded on desktop, Icon on mobile)
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
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Open Search Delegate
              },
            ),

          const SizedBox(width: 8),

          // Notification Icon
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),

          const SizedBox(width: 8),

          // Profile Button with Avatar
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryColor,
                      backgroundImage: _getAvatarImage(user),
                      child: _getAvatarImage(user) == null
                          ? Text(
                              _getAvatarInitial(user).toUpperCase(),
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                );
              }
              return IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/profile'));
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      // 3. Common Drawer (Left Side Menu)
      drawer: NavigationDrawer(
        selectedIndex: -1, // Don't use index-based selection
        onDestinationSelected: (index) {
          try {
            Navigator.pop(context); // Close drawer
            if (index < widget.sideNavigationItems.length) {
              widget.onNavigationSelected(widget.sideNavigationItems[index].route);
            }
          } catch (e) {
            debugPrint('Error in drawer navigation: $e');
          }
        },
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...widget.sideNavigationItems.map(
            (item) => NavigationDrawerDestination(
              icon: _isRouteSelected(currentRoute, item.route) ? Icon(item.selectedIcon ?? item.icon) : Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon ?? item.icon),
              label: Text(item.label),
            ),
          ),
          const Divider(indent: 28, endIndent: 28),
          // Common Settings Section
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          // Theme Toggle
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

      // 4. Responsive Body Layout
      body: Row(
        children: [
          // Tablet/Desktop: Show Rail on the side
          if (!isMobile)
            SizedBox(
              width: isDesktop ? 256 : 80, // Fixed width: 256 for extended, 80 for compact
              child: NavigationRail(
                extended: isDesktop, // Text labels visible on Desktop
                selectedIndex: -1, // Don't use index-based selection
                onDestinationSelected: (index) {
                  try {
                    widget.onNavigationSelected(widget.sideNavigationItems[index].route);
                  } catch (e) {
                    debugPrint('Error in navigation rail: $e');
                  }
                },
                labelType: isDesktop ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                destinations: widget.sideNavigationItems
                    .map(
                      (item) => NavigationRailDestination(
                        icon: _isRouteSelected(currentRoute, item.route)
                            ? Icon(item.selectedIcon ?? item.icon)
                            : Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon ?? item.icon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
              ),
            ),

          if (!isMobile) const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(child: widget.child),
        ],
      ),

      // 5. Mobile: Show Bottom Bar
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _getSelectedBottomNavIndex(currentRoute),
              onDestinationSelected: (index) {
                try {
                  widget.onNavigationSelected(widget.bottomNavigationitems[index].route);
                } catch (e) {
                  debugPrint('Error in bottom navigation: $e');
                }
              },
              destinations: widget.bottomNavigationitems
                  .map(
                    (item) => NavigationDestination(
                      icon: _isRouteSelected(currentRoute, item.route)
                          ? Icon(item.selectedIcon ?? item.icon)
                          : Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon ?? item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            )
          : null, // No bottom bar on tablet/desktop
    );
  }
}
