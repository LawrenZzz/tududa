import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/constants.dart';

/// Authentication state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? serverUrl;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.serverUrl,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? serverUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Check if server is configured and user is logged in
  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString(AppConstants.serverUrlKey);

      if (serverUrl == null || serverUrl.isEmpty) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      state = state.copyWith(serverUrl: serverUrl);

      // Initialize API service
      await ApiService.instance.init(serverUrl: serverUrl);

      // Check if we have a valid session
      final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;
      if (!isLoggedIn) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      // Verify session with server
      final response = await ApiService.instance.getCurrentUser();
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>?;
        if (userData != null) {
          final user = User.fromJson(userData);
          await _saveUserData(prefs, user);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          return;
        }
      }

      // Session invalid, try to use cached user data
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('Auth check error: $e');
      // Try offline mode with cached data
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(AppConstants.userDataKey);
      if (cachedData != null) {
        try {
          final user = User.fromJson(jsonDecode(cachedData));
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          return;
        } catch (_) {}
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Unable to verify session',
      );
    }
  }

  /// Configure server URL
  Future<bool> configureServer(String url) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      // Normalize URL
      String serverUrl = url.trim();
      if (serverUrl.endsWith('/')) {
        serverUrl = serverUrl.substring(0, serverUrl.length - 1);
      }
      if (!serverUrl.startsWith('http://') && !serverUrl.startsWith('https://')) {
        serverUrl = 'https://$serverUrl';
      }

      // Save and initialize
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.serverUrlKey, serverUrl);
      await ApiService.instance.init(serverUrl: serverUrl);

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        serverUrl: serverUrl,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to connect to server: $e',
      );
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final response = await ApiService.instance.login(email, password);

      if (response.statusCode == 200 && response.data != null) {
        // Login response directly includes user data: {"user": {...}}
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>?;
        if (userData != null) {
          final user = User.fromJson(userData);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstants.isLoggedInKey, true);
          await _saveUserData(prefs, user);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          return true;
        }
      }

      // Handle error response
      final data = response.data;
      String errorMsg = 'Invalid credentials';
      if (data is Map<String, dynamic>) {
        errorMsg = data['error']?.toString() ??
            (data['errors'] is List ? (data['errors'] as List).join(', ') : errorMsg);
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: errorMsg,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Login failed: $e',
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await ApiService.instance.logout();
    } catch (_) {}

    await ApiService.instance.clearCookies();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, false);
    await prefs.remove(AppConstants.userDataKey);

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear server config (go back to server setup)
  Future<void> clearServerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.serverUrlKey);
    await prefs.remove(AppConstants.isLoggedInKey);
    await prefs.remove(AppConstants.userDataKey);
    await ApiService.instance.clearCookies();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _saveUserData(SharedPreferences prefs, User user) async {
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
