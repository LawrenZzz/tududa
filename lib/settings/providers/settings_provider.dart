import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/strings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

enum AppThemeMode { light, dark, system }

class AppSettings {
  final AppThemeMode themeMode;
  final String locale;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.locale = 'zh', // Default to Chinese
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? locale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeKey = 'app_theme_mode';
  static const _localeKey = 'app_locale';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    
    final themeStr = prefs.getString(_themeKey) ?? 'system';
    final themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => AppThemeMode.system,
    );
    
    final locale = prefs.getString(_localeKey) ?? 'zh';

    return AppSettings(themeMode: themeMode, locale: locale);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeKey, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(String locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localeKey, locale);
    state = state.copyWith(locale: locale);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

// A localized strings provider directly reading from settings
final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(settingsProvider.select((s) => s.locale));
  return AppStrings(locale);
});
