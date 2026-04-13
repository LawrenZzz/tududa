import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../common/widgets/glass_container.dart';

/// Shell scaffold with bottom navigation bar.
class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/tasks')) return 0;
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/notes')) return 2;
    if (location.startsWith('/inbox')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final strings = context.l10n;

    return Scaffold(
      extendBody: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: child,
      bottomNavigationBar: GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: NavigationBar(
          selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/tasks');
              break;
            case 1:
              context.go('/projects');
              break;
            case 2:
              context.go('/notes');
              break;
            case 3:
              context.go('/inbox');
              break;
            case 4:
              context.go('/more');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: strings.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: strings.projects,
          ),
          NavigationDestination(
            icon: const Icon(Icons.note_outlined),
            selectedIcon: const Icon(Icons.note),
            label: strings.notes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inbox_outlined),
            selectedIcon: const Icon(Icons.inbox),
            label: strings.inbox,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: strings.more,
          ),
        ],
        ),
      ),
    );
  }
}
