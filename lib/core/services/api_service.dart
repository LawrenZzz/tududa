import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

/// Dio HTTP client wrapper with cookie-based session management.
///
/// Handles:
/// - Cookie persistence for login state
/// - Request/response interceptors
/// - Base URL configuration
/// - Error handling
class ApiService {
  static ApiService? _instance;
  late Dio _dio;
  late PersistCookieJar _cookieJar;
  bool _initialized = false;

  ApiService._();

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  Dio get dio => _dio;
  PersistCookieJar get cookieJar => _cookieJar;
  bool get isInitialized => _initialized;

  /// Initialize the API service with the server URL.
  Future<void> init({String? serverUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = serverUrl ?? prefs.getString(AppConstants.serverUrlKey) ?? '';

    if (baseUrl.isEmpty) {
      _dio = Dio();
      return;
    }

    // Setup persistent cookie jar
    final appDocDir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );

    _dio = Dio(BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ));

    // Add cookie manager for session persistence
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Logging interceptor (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    // Error interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Session expired or unauthorized
          debugPrint('API: Unauthorized - session may have expired');
        }
        handler.next(error);
      },
    ));

    _initialized = true;
  }

  /// Update the base URL (e.g., when user changes server)
  Future<void> updateBaseUrl(String serverUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.serverUrlKey, serverUrl);
    await init(serverUrl: serverUrl);
  }

  /// Clear all cookies (logout)
  Future<void> clearCookies() async {
    if (_initialized) {
      await _cookieJar.deleteAll();
    }
  }

  // ---------- Auth API ----------

  Future<Response> login(String email, String password) async {
    return _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> logout() async {
    return _dio.post('/logout');
  }

  Future<Response> getCurrentUser() async {
    return _dio.get('/current_user');
  }

  // ---------- Tasks API ----------

  Future<Response> getTasks({Map<String, dynamic>? queryParams}) async {
    return _dio.get('/tasks', queryParameters: queryParams);
  }

  Future<Response> getTask(dynamic id) async {
    return _dio.get('/task/$id');
  }

  Future<Response> createTask(Map<String, dynamic> data) async {
    return _dio.post('/task', data: data);
  }

  Future<Response> updateTask(dynamic id, Map<String, dynamic> data) async {
    return _dio.put('/task/$id', data: data);
  }

  Future<Response> deleteTask(dynamic id) async {
    return _dio.delete('/task/$id');
  }

  Future<Response> getTaskMetrics() async {
    return _dio.get('/tasks/metrics');
  }

  Future<Response> getSubtasks(dynamic parentId) async {
    return _dio.get('/task/$parentId/subtasks');
  }

  Future<Response> createSubtask(dynamic parentId, Map<String, dynamic> data) async {
    return _dio.post('/task/$parentId/subtask', data: data);
  }

  Future<Response> reorderSubtasks(dynamic parentId, List<Map<String, dynamic>> order) async {
    return _dio.put('/task/$parentId/subtasks/reorder', data: {'order': order});
  }

  // ---------- Projects API ----------

  Future<Response> getProjects({Map<String, dynamic>? queryParams}) async {
    return _dio.get('/projects', queryParameters: queryParams);
  }

  Future<Response> getProject(dynamic id) async {
    return _dio.get('/project/$id');
  }

  Future<Response> createProject(Map<String, dynamic> data) async {
    return _dio.post('/project', data: data);
  }

  Future<Response> updateProject(dynamic id, Map<String, dynamic> data) async {
    return _dio.put('/project/$id', data: data);
  }

  Future<Response> deleteProject(dynamic id) async {
    return _dio.delete('/project/$id');
  }

  // ---------- Notes API ----------

  Future<Response> getNotes({Map<String, dynamic>? queryParams}) async {
    return _dio.get('/notes', queryParameters: queryParams);
  }

  Future<Response> getNote(dynamic id) async {
    return _dio.get('/note/$id');
  }

  Future<Response> createNote(Map<String, dynamic> data) async {
    return _dio.post('/note', data: data);
  }

  Future<Response> updateNote(dynamic id, Map<String, dynamic> data) async {
    return _dio.put('/note/$id', data: data);
  }

  Future<Response> deleteNote(dynamic id) async {
    return _dio.delete('/note/$id');
  }

  // ---------- Areas API ----------

  Future<Response> getAreas() async {
    return _dio.get('/areas');
  }

  Future<Response> createArea(Map<String, dynamic> data) async {
    return _dio.post('/area', data: data);
  }

  Future<Response> updateArea(dynamic id, Map<String, dynamic> data) async {
    return _dio.put('/area/$id', data: data);
  }

  Future<Response> deleteArea(dynamic id) async {
    return _dio.delete('/area/$id');
  }

  // ---------- Tags API ----------

  Future<Response> getTags() async {
    return _dio.get('/tags');
  }

  Future<Response> createTag(Map<String, dynamic> data) async {
    return _dio.post('/tag', data: data);
  }

  Future<Response> deleteTag(dynamic id) async {
    return _dio.delete('/tag/$id');
  }

  // ---------- Inbox API ----------

  Future<Response> getInboxItems() async {
    return _dio.get('/inbox');
  }

  Future<Response> updateInboxItem(dynamic id, Map<String, dynamic> data) async {
    return _dio.put('/inbox/$id', data: data);
  }

  Future<Response> deleteInboxItem(dynamic id) async {
    return _dio.delete('/inbox/$id');
  }

  // ---------- Settings API ----------

  Future<Response> updateUserSettings(Map<String, dynamic> data) async {
    return _dio.put('/profile', data: data);
  }

  Future<Response> updateSidebarSettings(Map<String, dynamic> data) async {
    return _dio.put('/profile/sidebar-settings', data: data);
  }

  Future<Response> updateTodaySettings(Map<String, dynamic> data) async {
    return _dio.put('/profile/today-settings', data: data);
  }
}
