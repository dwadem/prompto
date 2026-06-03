import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hosts the three primary tabs. Uses [NavigationBar] (Material 3); on a wide
/// screen it switches to a [NavigationRail] so tablets/foldables and (later)
/// iPad get a sensible layout for free.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    _Dest(Icons.school_outlined, Icons.school, 'Learn'),
    _Dest(Icons.menu_book_outlined, Icons.menu_book, 'Library'),
    _Dest(Icons.person_outline, Icons.person, 'Profile'),
  ];

  void _go(int index) => shell.goBranch(
        index,
        // Re-tapping the active tab pops to its root.
        initialLocation: index == shell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _go,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Dest {
  const _Dest(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
