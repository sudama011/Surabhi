// lib/core/widgets/app_shell.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/models/navigation_item.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/routes/app_navigator.dart';
import 'package:surabhi/injector.dart';
import 'package:surabhi/routes/app_routes.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final List<NavigationItem> sideNavigationItems;
  final List<NavigationItem> bottomNavigationitems;
  final AppNavigator appNavigator = sl<AppNavigator>();

  AppShell({super.key, required this.child, required this.sideNavigationItems, required this.bottomNavigationitems});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavigationItem? _findMatchingItem(String currentRoute, List<NavigationItem> items) {
    NavigationItem? bestMatch;
    int maxMatchLength = -1;

    for (var item in items) {
      // 1. Exact Match (Best case)
      if (item.route == currentRoute) return item;

      // 2. Prefix Match
      if (currentRoute.startsWith(item.route)) {
        // Prevent partial word matches (e.g. /users matching /userslist)
        // Only match if the next char is '/' or it's the end of string
        bool isBoundaryCorrect = currentRoute.length == item.route.length || currentRoute[item.route.length] == '/';

        if (isBoundaryCorrect && item.route.length > maxMatchLength) {
          maxMatchLength = item.route.length;
          bestMatch = item;
        }
      }
    }
    return bestMatch;
  }

  int? _getSelectedIndex(String currentRoute, List<NavigationItem> items) {
    final match = _findMatchingItem(currentRoute, items);
    if (match != null) {
      return items.indexOf(match);
    }
    return null;
  }

  String _getPageTitle(String currentRoute) {
    if (currentRoute == AppRoutes.settings) return 'Settings';
    if (currentRoute == AppRoutes.profile) return 'Profile';

    final allItems = [...widget.sideNavigationItems, ...widget.bottomNavigationitems];

    // FIX: Use the smart matcher
    final match = _findMatchingItem(currentRoute, allItems);
    if (match != null) return match.label;

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

    // 1. RAIL ITEMS (Desktop)
    final List<NavigationItem> railItems = isMobile
        ? []
        : [
            ...widget.sideNavigationItems,
            ...widget.bottomNavigationitems,
            // Settings Item (Always at bottom of rail)
            const NavigationItem(label: 'Settings', icon: Icons.settings, route: AppRoutes.settings),
          ];

    // Calculate Indices
    final int? bottomNavIndex = _getSelectedIndex(currentRoute, widget.bottomNavigationitems);
    final int? railIndex = _getSelectedIndex(currentRoute, railItems);

    if (widget.sideNavigationItems.isEmpty && widget.bottomNavigationitems.isEmpty) {
      return const Center(child: Text('No navigation items configured'));
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
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                return Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.profile),
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
              return IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => widget.appNavigator.push(AppRoutes.profile),
              );
            },
          ),
        ],
      ),

      // NOTE: NavigationDrawer's 'children' list allows mixing Destinations and Widgets.
      // However, if we mix them, the 'selectedIndex' might visually misalign if we aren't careful.
      // A cleaner way for the Drawer manual item is strictly using standard ListTiles below the NavigationDrawerDestination list.
      // Let's refine the Drawer above to be safe:

      /* REFINED DRAWER IMPLEMENTATION */
      /* Replace the 'drawer:' parameter above with this robust version: */
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Header or Spacing
                  const SizedBox(height: kToolbarHeight + 16),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
                    child: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),

                  // Dynamic Items
                  ...widget.sideNavigationItems
                      .map((item) {
                        return NavigationDrawerDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon ?? item.icon),
                          label: Text(item.label),
                          // We wrap this in a Theme/Config wrapper if we used the NavigationDrawer widget,
                          // but inside a ListView, we use ListTile for total control.
                        );
                        // actually, let's use standard ListTiles to be 100% safe with your custom mix
                      })
                      .map((dest) {
                        // Manual mapping to ListTile for the 'Drawer' widget
                        // (Since NavigationDrawer widget is strict about its children)
                        final item = widget.sideNavigationItems.firstWhere(
                          (i) => Text(i.label).data == (dest.label as Text).data,
                        );
                        final isSelected = currentRoute == item.route;

                        return ListTile(
                          leading: isSelected ? dest.selectedIcon : dest.icon,
                          title: dest.label,
                          selected: isSelected,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), // Material 3 style
                          contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                          onTap: () {
                            Navigator.pop(context);
                            widget.appNavigator.push(item.route);
                          },
                        );
                      }),

                  const Divider(indent: 28, endIndent: 28, height: 32),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(28, 0, 16, 10),
                    child: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),

                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('All Settings'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                    onTap: () {
                      Navigator.pop(context);
                      widget.appNavigator.push(AppRoutes.settings);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3. RAIL (Desktop/Tablet)
          if (!isMobile && railItems.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraint) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraint.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        extended: isDesktop,
                        selectedIndex: railIndex,
                        onDestinationSelected: (index) {
                          if (index < railItems.length) {
                            final route = railItems[index].route;
                            if (route == AppRoutes.settings) {
                              widget.appNavigator.push(AppRoutes.settings);
                            } else {
                              widget.appNavigator.push(route);
                            }
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
                  widget.appNavigator.push(widget.bottomNavigationitems[index].route);
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
