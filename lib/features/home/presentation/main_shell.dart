import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/localization/app_localizations.dart';

/// Bottom navigation shell hosting the five primary tabs.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: context.tr('nav_home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calculate_outlined),
              selectedIcon: const Icon(Icons.calculate_rounded),
              label: context.tr('nav_calculator'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_rounded),
              label: context.tr('nav_history'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_rounded),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: context.tr('nav_tools'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: context.tr('nav_settings'),
            ),
          ],
        ),
      ),
    );
  }
}
