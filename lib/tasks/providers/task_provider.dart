import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../../core/services/api_service.dart';

/// Task filter enum matching tududi's view
enum TaskFilter { today, upcoming, someday, completed, all }

/// Task sort options
enum TaskSort { name, dueDate, createdAt, priority }

class TaskListState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final TaskFilter filter;
  final TaskSort sort;
  final bool sortAscending;

  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.filter = TaskFilter.today,
    this.sort = TaskSort.dueDate,
    this.sortAscending = true,
  });

  TaskListState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    TaskFilter? filter,
    TaskSort? sort,
    bool? sortAscending,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskListState> {
  TaskNotifier() : super(const TaskListState());

  Future<void> loadTasks({TaskFilter? filter}) async {
    if (filter != null) {
      state = state.copyWith(filter: filter);
    }

    state = state.copyWith(isLoading: true);

    try {
      final queryParams = <String, dynamic>{};

      switch (state.filter) {
        case TaskFilter.today:
          queryParams['filter'] = 'today';
          break;
        case TaskFilter.upcoming:
          queryParams['filter'] = 'upcoming';
          break;
        case TaskFilter.someday:
          queryParams['filter'] = 'someday';
          break;
        case TaskFilter.completed:
          queryParams['filter'] = 'completed';
          break;
        case TaskFilter.all:
          break;
      }

      final response = await ApiService.instance.getTasks(queryParams: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['tasks'] ?? []);
        final tasks = data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(tasks: tasks, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load tasks',
        );
      }
    } catch (e) {
      debugPrint('Load tasks error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading tasks: $e',
      );
    }
  }

  Future<bool> createTask(Task task) async {
    try {
      final response = await ApiService.instance.createTask(task.toJson());
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 302) {
        await loadTasks();
        return true;
      }
      debugPrint('Create task failed: status=${response.statusCode}, body=${response.data}');
      return false;
    } catch (e) {
      debugPrint('Create task error: $e');
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      // Server PATCH route uses uid
      final taskId = task.uid ?? task.id?.toString();
      if (taskId == null) {
        debugPrint('Update task error: no id or uid available');
        return false;
      }
      final data = task.toJson();
      debugPrint('Updating task $taskId with data: $data');
      final response = await ApiService.instance.updateTask(taskId, data);
      debugPrint('Update task response: status=${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 302) {
        await loadTasks();
        return true;
      }
      debugPrint('Update task failed: status=${response.statusCode}, body=${response.data}');
      return false;
    } catch (e) {
      debugPrint('Update task error: $e');
      return false;
    }
  }

  Future<bool> toggleTaskComplete(Task task) async {
    try {
      final taskId = task.id?.toString() ?? task.uid;
      if (taskId == null) return false;
      final newStatus = task.isCompleted ? 0 : 2;
      final response = await ApiService.instance.updateTask(
        taskId,
        {'status': newStatus},
      );
      if (response.statusCode == 200 || response.statusCode == 302) {
        await loadTasks();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTaskStatus(dynamic id, int status) async {
    try {
      if (id == null) return false;
      final response = await ApiService.instance.updateTask(
        id,
        {'status': status},
      );
      if (response.statusCode == 200) {
        await loadTasks();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTask(dynamic id) async {
    try {
      final response = await ApiService.instance.deleteTask(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await loadTasks();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void setFilter(TaskFilter filter) {
    loadTasks(filter: filter);
  }

  void setSort(TaskSort sort, {bool? ascending}) {
    state = state.copyWith(
      sort: sort,
      sortAscending: ascending ?? state.sortAscending,
    );
    _sortTasks();
  }

  void _sortTasks() {
    final sorted = List<Task>.from(state.tasks);
    sorted.sort((a, b) {
      int result;
      switch (state.sort) {
        case TaskSort.name:
          result = a.name.compareTo(b.name);
          break;
        case TaskSort.dueDate:
          final aDate = a.dueDate ?? DateTime(2099);
          final bDate = b.dueDate ?? DateTime(2099);
          result = aDate.compareTo(bDate);
          break;
        case TaskSort.createdAt:
          final aDate = a.createdAt ?? DateTime(2099);
          final bDate = b.createdAt ?? DateTime(2099);
          result = aDate.compareTo(bDate);
          break;
        case TaskSort.priority:
          result = b.priority.compareTo(a.priority);
          break;
      }
      return state.sortAscending ? result : -result;
    });
    state = state.copyWith(tasks: sorted);
  }
}

/// Task list provider
final taskListProvider = StateNotifierProvider<TaskNotifier, TaskListState>((ref) {
  return TaskNotifier();
});

/// Single task provider
final taskDetailProvider = FutureProvider.family<Task?, dynamic>((ref, id) async {
  try {
    final response = await ApiService.instance.getTask(id);
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : response.data['task'];
      if (data != null) {
        return Task.fromJson(data as Map<String, dynamic>);
      }
    }
  } catch (e) {
    debugPrint('Task detail error: $e');
  }
  return null;
});
