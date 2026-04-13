import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/server_config_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../tasks/screens/task_detail_screen.dart';
import '../../tasks/screens/task_form_screen.dart';
import '../../projects/screens/projects_screen.dart';
import '../../projects/screens/project_detail_screen.dart';
import '../../projects/screens/project_form_screen.dart';
import '../../notes/screens/notes_screen.dart';
import '../../notes/screens/note_editor_screen.dart';
import '../../inbox/screens/inbox_screen.dart';
import '../../areas/screens/areas_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../common/widgets/shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/tasks',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final hasServer = authState.serverUrl != null && authState.serverUrl!.isNotEmpty;

      final currentPath = state.matchedLocation;
      final isAuthRoute = currentPath == '/login' ||
          currentPath == '/server-config';

      if (isLoading) return null;

      if (!isAuth) {
        if (!hasServer && currentPath != '/server-config') {
          return '/server-config';
        }
        if (hasServer && currentPath != '/login' && currentPath != '/server-config') {
          return '/login';
        }
        return null;
      }

      // Authenticated, redirect away from auth pages
      if (isAuthRoute) return '/tasks';

      return null;
    },
    routes: [
      // Auth routes (full screen, no shell)
      GoRoute(
        path: '/server-config',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ServerConfigScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // Main app with shell (bottom navigation)
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const TaskFormScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TaskDetailScreen(taskId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return TaskFormScreen(taskId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const ProjectFormScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProjectDetailScreen(projectId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ProjectFormScreen(projectId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/notes',
            builder: (context, state) => const NotesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const NoteEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return NoteEditorScreen(noteId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/inbox',
            builder: (context, state) => const InboxScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'areas',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const AreasScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
