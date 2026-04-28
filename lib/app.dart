import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

import 'settings/providers/settings_provider.dart';

/// Root application widget.
class TududiApp extends ConsumerWidget {
  const TududiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    ThemeMode mode;
    switch (settings.themeMode) {
      case AppThemeMode.light:
        mode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        mode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
      default:
        mode = ThemeMode.system;
    }

    return MaterialApp.router(
      title: 'Tududa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
