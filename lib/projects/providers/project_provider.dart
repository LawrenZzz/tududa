import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../../core/services/api_service.dart';

class ProjectListState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;

  const ProjectListState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
  });

  ProjectListState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectListState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectListState> {
  ProjectNotifier() : super(const ProjectListState());

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await ApiService.instance.getProjects();

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['projects'] ?? []);
        final projects = data
            .map((e) => Project.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(projects: projects, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load projects');
      }
    } catch (e) {
      debugPrint('Load projects error: $e');
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  Future<bool> createProject(Project project) async {
    try {
      final response = await ApiService.instance.createProject(project.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadProjects();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProject(Project project) async {
    try {
      if (project.id == null) return false;
      final response = await ApiService.instance.updateProject(
        project.id!,
        project.toJson(),
      );
      if (response.statusCode == 200) {
        await loadProjects();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProject(dynamic id) async {
    try {
      final response = await ApiService.instance.deleteProject(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await loadProjects();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final projectListProvider =
    StateNotifierProvider<ProjectNotifier, ProjectListState>((ref) {
  return ProjectNotifier();
});

final projectDetailProvider =
    FutureProvider.family<Project?, dynamic>((ref, id) async {
  try {
    final response = await ApiService.instance.getProject(id);
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : response.data['project'];
      if (data != null) {
        return Project.fromJson(data as Map<String, dynamic>);
      }
    }
  } catch (e) {
    debugPrint('Project detail error: $e');
  }
  return null;
});
