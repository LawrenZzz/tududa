import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../../l10n/strings.dart';

/// Settings / More screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final strings = context.l10n;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.more)),
      body: ListView(
        children: [
          // User info card
          if (user != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          _SectionHeader(title: strings.navigation),

          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: Text(strings.areas),
            subtitle: Text(strings.areasDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/more/areas'),
          ),

          _SectionHeader(title: strings.preferences),

          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(strings.appearance),
            trailing: DropdownButton<AppThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: AppThemeMode.light, child: Text(strings.lightMode)),
                DropdownMenuItem(value: AppThemeMode.dark, child: Text(strings.darkMode)),
                DropdownMenuItem(value: AppThemeMode.system, child: Text(strings.systemMode)),
              ],
              onChanged: (val) {
                if (val != null) ref.read(settingsProvider.notifier).setThemeMode(val);
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(strings.language),
            trailing: DropdownButton<String>(
              value: settings.locale,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'zh', child: Text('中文')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) ref.read(settingsProvider.notifier).setLocale(val);
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: Text(strings.timezone),
            subtitle: Text(user?.timezone ?? 'UTC'),
          ),

          _SectionHeader(title: strings.integrations),

          ListTile(
            leading: const Icon(Icons.send_outlined),
            title: const Text('Telegram'),
            subtitle: Text(
              user?.telegramChatId != null ? 'Connected' : 'Not configured',
            ),
          ),

          _SectionHeader(title: strings.server),

          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: Text(strings.serverUrl),
            subtitle: Text(authState.serverUrl ?? 'Not configured'),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(strings.about),
            subtitle: const Text('v1.0.0 • Open Source'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Tududa',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Chris Veleris. MIT License.',
              );
            },
          ),

          const Divider(height: 32),

          // Logout
          ListTile(
            leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            title: Text(strings.signOut,
                style: TextStyle(color: theme.colorScheme.error)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(strings.signOut),
                  content: Text(strings.signOutConfirm),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(strings.cancel)),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(strings.signOut)),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(authProvider.notifier).logout();
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
