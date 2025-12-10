import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final List<NavigationItem> items;
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final String pageTitle;

  // Optional: Actions for the top bar (e.g. Profile picture)
  final List<Widget>? actions;

  const AppShell({
    super.key,
    required this.child,
    required this.items,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.pageTitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppConstants.tablet;
    final isMobile = width < AppConstants.mobile;

    // Validate navigation items
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(pageTitle)),
        body: const Center(child: Text('No navigation items configured')),
      );
    }

    // Ensure currentIndex is within bounds
    final validIndex = currentIndex.clamp(0, items.length - 1);

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

          // Extra Actions (Profile, etc passed from parent)
          if (actions != null) ...actions!,

          const SizedBox(width: 16),
        ],
      ),

      // 3. Common Drawer (Left Side Menu)
      drawer: NavigationDrawer(
        selectedIndex: validIndex,
        onDestinationSelected: (index) {
          try {
            Navigator.pop(context); // Close drawer
            // Handle Profile and Logout separately
            if (index == items.length) {
              // Profile
              context.go('/profile');
            } else if (index == items.length + 1) {
              // Logout
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/', extra: false);
            } else if (index < items.length) {
              onDestinationSelected(index);
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
          ...items.map(
            (item) => NavigationDrawerDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon ?? item.icon),
              label: Text(item.label),
            ),
          ),
          const Divider(indent: 28, endIndent: 28),
          const NavigationDrawerDestination(icon: Icon(Icons.person_outlined), label: Text('Profile')),
          const NavigationDrawerDestination(icon: Icon(Icons.logout), label: Text('Logout')),
        ],
      ),

      // 4. Responsive Body Layout
      body: Row(
        children: [
          // Tablet/Desktop: Show Rail on the side
          if (!isMobile)
            NavigationRail(
              extended: isDesktop, // Text labels visible on Desktop
              selectedIndex: validIndex,
              onDestinationSelected: (index) {
                try {
                  onDestinationSelected(index);
                } catch (e) {
                  debugPrint('Error in navigation rail: $e');
                }
              },
              labelType: isDesktop ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              destinations: items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon ?? item.icon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),

          if (!isMobile) const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(child: child),
        ],
      ),

      // 5. Mobile: Show Bottom Bar
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: validIndex,
              onDestinationSelected: (index) {
                try {
                  onDestinationSelected(index);
                } catch (e) {
                  debugPrint('Error in bottom navigation: $e');
                }
              },
              destinations: items
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
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
