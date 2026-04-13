import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../../core/theme/app_theme.dart';

/// Task detail screen showing full task info, subtasks, and actions.
class TaskDetailScreen extends ConsumerWidget {
  final dynamic taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final theme = Theme.of(context);

    return taskAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (task) {
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Task not found')),
          );
        }

        final priorityColor =
            AppTheme.getPriorityColor(task.priority, theme.colorScheme);

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/tasks/$taskId/edit'),
              ),
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                            'Are you sure you want to delete this task?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await ref
                          .read(taskListProvider.notifier)
                          .deleteTask(taskId);
                      if (context.mounted) context.pop();
                    }
                  } else if (action == 'toggle') {
                    await ref
                        .read(taskListProvider.notifier)
                        .toggleTaskComplete(task);
                    ref.invalidate(taskDetailProvider(taskId));
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(task.isCompleted
                        ? 'Mark as Incomplete'
                        : 'Mark as Complete'),
                  ),
                  const PopupMenuItem(
                      value: 'delete',
                      child:
                          Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status & Priority chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: task.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      label: task.statusName,
                      color: task.isCompleted
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                    _InfoChip(
                      icon: Icons.flag_rounded,
                      label: task.priorityName,
                      color: priorityColor,
                    ),
                    if (task.isRecurring)
                      _InfoChip(
                        icon: Icons.repeat_rounded,
                        label: _recurrenceLabel(task),
                        color: theme.colorScheme.tertiary,
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  task.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Meta info
                if (task.dueDate != null)
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Due',
                    value: DateFormat.yMMMd().format(task.dueDate!),
                    isOverdue: task.dueDate!.isBefore(DateTime.now()) &&
                        !task.isCompleted,
                  ),
                if (task.deferUntil != null)
                  _MetaRow(
                    icon: Icons.schedule_outlined,
                    label: 'Defer until',
                    value: DateFormat.yMMMd().format(task.deferUntil!),
                  ),
                if (task.projectName != null)
                  _MetaRow(
                    icon: Icons.folder_outlined,
                    label: 'Project',
                    value: task.projectName!,
                  ),
                if (task.completedAt != null)
                  _MetaRow(
                    icon: Icons.check_circle_outline,
                    label: 'Completed',
                    value: DateFormat.yMMMd().format(task.completedAt!),
                  ),

                // Tags
                if (task.tags != null && task.tags!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: task.tags!
                        .map((tag) => Chip(
                              label: Text(tag.name,
                                  style: theme.textTheme.labelSmall),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],

                // Note / Description
                if (task.note != null && task.note!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  MarkdownBody(
                    data: task.note!,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(
                      p: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],

                // Subtasks
                if (task.hasSubtasks) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Subtasks',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...task.subtasks!.map((sub) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          sub.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: sub.isCompleted
                              ? Colors.green
                              : theme.colorScheme.outline,
                          size: 22,
                        ),
                        title: Text(
                          sub.name,
                          style: TextStyle(
                            decoration: sub.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        dense: true,
                      )),
                ],

                // Habit info
                if (task.habitMode) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Habit Tracker',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HabitStat(
                          label: 'Current Streak',
                          value: '${task.habitCurrentStreak}'),
                      const SizedBox(width: 24),
                      _HabitStat(
                          label: 'Best Streak',
                          value: '${task.habitBestStreak}'),
                      const SizedBox(width: 24),
                      _HabitStat(
                          label: 'Total',
                          value: '${task.habitTotalCompletions}'),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  String _recurrenceLabel(Task task) {
    final interval = task.recurrenceInterval ?? 1;
    switch (task.recurrenceType) {
      case 'daily':
        return interval == 1 ? 'Daily' : 'Every $interval days';
      case 'weekly':
        return interval == 1 ? 'Weekly' : 'Every $interval weeks';
      case 'monthly':
        return interval == 1 ? 'Monthly' : 'Every $interval months';
      case 'monthly_weekday':
        return 'Monthly (weekday)';
      case 'monthly_last_day':
        return 'Monthly (last day)';
      default:
        return task.recurrenceType;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isOverdue;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isOverdue
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text('$label: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

class _HabitStat extends StatelessWidget {
  final String label;
  final String value;
  const _HabitStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
