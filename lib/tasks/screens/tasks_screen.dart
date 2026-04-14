import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../../core/theme/app_theme.dart';
import '../../common/widgets/glass_container.dart';
import '../../projects/widgets/kanban_board.dart';
import '../../l10n/strings.dart';

/// Main tasks screen with filter tabs (Today/Upcoming/Someday/Completed).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _isKanbanView = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(taskListProvider.notifier).loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskState = ref.watch(taskListProvider);
    final strings = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tasks),
        actions: [
          // Kanban/List toggle
          IconButton(
            icon: Icon(_isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_rounded),
            tooltip: _isKanbanView ? strings.list : strings.board,
            onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
          ),
          PopupMenuButton<TaskSort>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            onSelected: (sort) {
              ref.read(taskListProvider.notifier).setSort(sort);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: TaskSort.priority, child: Text('Priority')),
              const PopupMenuItem(value: TaskSort.dueDate, child: Text('Due Date')),
              const PopupMenuItem(value: TaskSort.name, child: Text('Name')),
              const PopupMenuItem(value: TaskSort.createdAt, child: Text('Date Created')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: TaskFilter.values.map((filter) {
                final isSelected = taskState.filter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(filter, strings)),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(taskListProvider.notifier).setFilter(filter);
                    },
                    showCheckmark: false,
                    avatar: isSelected
                        ? null
                        : Icon(_filterIcon(filter),
                            size: 18, color: theme.colorScheme.onSurfaceVariant),
                  ),
                );
              }).toList(),
            ),
          ),

          // Task content (list or kanban)
          Expanded(
            child: taskState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : taskState.error != null
                    ? _ErrorView(
                        error: taskState.error!,
                        onRetry: () =>
                            ref.read(taskListProvider.notifier).loadTasks(),
                      )
                    : taskState.tasks.isEmpty
                        ? _EmptyView(filter: taskState.filter)
                        : _isKanbanView
                            ? // Kanban board view
                              KanbanBoard(
                                tasks: taskState.tasks,
                                onTaskTap: (task) {
                                  final id = task.uid ?? task.id?.toString();
                                  if (id != null) context.push('/tasks/$id');
                                },
                                onTaskStatusChanged: (task, newStatus) async {
                                  final taskId = task.uid ?? task.id?.toString();
                                  if (taskId == null) return;
                                  await ref.read(taskListProvider.notifier).updateTaskStatus(taskId, newStatus);
                                },
                              )
                            : // List view
                              RefreshIndicator(
                                onRefresh: () =>
                                    ref.read(taskListProvider.notifier).loadTasks(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 88),
                                  itemCount: taskState.tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = taskState.tasks[index];
                                    return _TaskListItem(
                                      task: task,
                                      onTap: () {
                                        final id = task.uid ?? task.id?.toString();
                                        if (id != null) {
                                          context.push('/tasks/$id');
                                        }
                                      },
                                      onToggle: () {
                                        ref
                                            .read(taskListProvider.notifier)
                                            .toggleTaskComplete(
                                                taskState.tasks[index]);
                                      },
                                    );
                                  },
                                ),
                              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/new'),
        icon: const Icon(Icons.add_rounded),
        label: Text(strings.newTask),
      ),
    );
  }

  String _filterLabel(TaskFilter filter, AppStrings strings) {
    switch (filter) {
      case TaskFilter.today:
        return strings.today;
      case TaskFilter.upcoming:
        return strings.upcoming;
      case TaskFilter.someday:
        return strings.someday;
      case TaskFilter.completed:
        return strings.completed;
      case TaskFilter.all:
        return strings.isZh ? '全部' : 'All';
    }
  }

  IconData _filterIcon(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.today:
        return Icons.today_outlined;
      case TaskFilter.upcoming:
        return Icons.upcoming_outlined;
      case TaskFilter.someday:
        return Icons.cloud_outlined;
      case TaskFilter.completed:
        return Icons.check_circle_outline;
      case TaskFilter.all:
        return Icons.list_rounded;
    }
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _TaskListItem({
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = AppTheme.getPriorityColor(task.priority, theme.colorScheme);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: task.isCompleted
                  ? theme.colorScheme.primary
                  : priorityColor.withValues(alpha: 0.6),
              width: 2,
            ),
            color: task.isCompleted
                ? theme.colorScheme.primary
                : Colors.transparent,
          ),
          child: task.isCompleted
              ? Icon(Icons.check_rounded,
                  size: 16, color: theme.colorScheme.onPrimary)
              : null,
        ),
      ),
      title: Text(
        task.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
      onTap: onTap,
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <Widget>[];

    if (task.projectName != null) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined,
              size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Flexible(
            child: Text(task.projectName!,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ));
    }

    if (task.dueDate != null) {
      final isOverdue =
          task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded,
              size: 12,
              color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            DateFormat.MMMd().format(task.dueDate!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isOverdue ? theme.colorScheme.error : null,
              fontWeight: isOverdue ? FontWeight.w600 : null,
            ),
          ),
        ],
      ));
    }

    if (task.isRecurring) {
      parts.add(Icon(Icons.repeat_rounded,
          size: 14, color: theme.colorScheme.tertiary));
    }

    if (parts.isEmpty) return null;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 12, runSpacing: 4, children: parts),
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    final theme = Theme.of(context);
    if (task.priority >= 1) {
      final color = AppTheme.getPriorityColor(task.priority, theme.colorScheme);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          task.priority == 2 ? '!!!' : '!!',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
    }
    return null;
  }
}

class _EmptyView extends StatelessWidget {
  final TaskFilter filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.l10n;
    String message;
    IconData icon;
    switch (filter) {
      case TaskFilter.today:
        message = strings.noTasksToday;
        icon = Icons.celebration_outlined;
        break;
      case TaskFilter.completed:
        message = strings.noCompletedTasks;
        icon = Icons.check_circle_outline;
        break;
      default:
        message = strings.noTasksYet;
        icon = Icons.task_outlined;
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}
