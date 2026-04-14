import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/project_provider.dart';
import '../../common/widgets/glass_container.dart';
import '../../tasks/models/task_model.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/kanban_board.dart';
import '../../tasks/providers/task_provider.dart';
import '../../l10n/strings.dart';

/// Project detail screen with tasks and notes.
class ProjectDetailScreen extends ConsumerStatefulWidget {
  final dynamic projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  List<Task> _tasks = [];
  bool _loadingTasks = true;
  bool _isKanbanView = true;
  int? _numericProjectId; // Cache the numeric project id for filtering

  @override
  void initState() {
    super.initState();
    // Don't load tasks here - wait for project detail to provide numeric ID
  }

  Future<void> _loadProjectTasks() async {
    if (_numericProjectId == null) return; // Can't filter without numeric id
    setState(() => _loadingTasks = true);
    try {
      final response = await ApiService.instance.getTasks(
        queryParams: {'project_id': widget.projectId},
      );
      if (response.statusCode == 200 && mounted) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['tasks'] ?? []);
        final allTasks = data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
        // Client-side filter: only keep tasks that belong to this project
        final filteredTasks = allTasks.where((t) => t.projectId == _numericProjectId).toList();
        setState(() {
          _tasks = filteredTasks;
          _loadingTasks = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingTasks = false);
    }
  }

  /// Called once we have the project detail to set the numeric id and load tasks
  void _onProjectLoaded(int projectId) {
    if (_numericProjectId != projectId) {
      _numericProjectId = projectId;
      _loadProjectTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));
    final strings = context.l10n;

    return projectAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(strings.noProjectsYet)),
          );
        }

        // Set numeric project id and trigger task loading on first load
        if (project.id != null && _numericProjectId != project.id) {
          Future.microtask(() => _onProjectLoaded(project.id!));
        }

        final statusColor = AppTheme.getProjectStatusColor(
            project.status, theme.colorScheme);

        return Scaffold(
          appBar: AppBar(
            title: Text(project.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/projects/${widget.projectId}/edit'),
              ),
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(strings.isZh ? '删除项目' : 'Delete Project'),
                        content: Text(strings.isZh ? '这将删除该项目及其所有任务。' : 'This will delete the project and all its tasks.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(strings.cancel)),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(strings.isZh ? '删除' : 'Delete')),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await ref.read(projectListProvider.notifier).deleteProject(widget.projectId);
                      if (context.mounted) context.pop();
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(projectDetailProvider(widget.projectId));
              await _loadProjectTasks();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Project header card
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(project.statusDisplay,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                            ),
                            const Spacer(),
                            if (project.priority != null)
                              Icon(Icons.flag_rounded,
                                  color: AppTheme.getStringPriorityColor(project.priority, theme.colorScheme),
                                  size: 20),
                          ],
                        ),
                        if (project.description != null && project.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(project.description!, style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                        ],
                        if (project.areaName != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.layers_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text('Area: ${project.areaName}', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Tasks section
                Row(
                  children: [
                    Text(strings.projectTasks, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.push('/tasks/new?projectId=${project.id}'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(strings.addTask),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        icon: const Icon(Icons.view_kanban_rounded),
                        label: Text(strings.board),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: const Icon(Icons.view_list_rounded),
                        label: Text(strings.list),
                      ),
                    ],
                    selected: {_isKanbanView},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _isKanbanView = newSelection.first;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 4),
                if (_loadingTasks)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                else if (_tasks.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(strings.noTasksYet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ),
                    ),
                  )
                else if (_isKanbanView)
                  SizedBox(
                    height: 500, // Fixed height for horizontal board
                    child: KanbanBoard(
                      tasks: _tasks,
                      onTaskTap: (task) {
                        final id = task.uid ?? task.id?.toString();
                        if (id != null) context.push('/tasks/$id');
                      },
                      onTaskStatusChanged: (task, newStatus) async {
                        final taskId = task.uid ?? task.id?.toString();
                        if (taskId == null) return;
                        
                        // Optimistic update
                        setState(() {
                          final index = _tasks.indexWhere((t) => (t.uid ?? t.id?.toString()) == taskId);
                          if (index != -1) {
                            _tasks[index] = task.copyWith(status: newStatus);
                          }
                        });
                        
                        // Background update API
                        await ref.read(taskListProvider.notifier).updateTaskStatus(taskId, newStatus);
                        _loadProjectTasks();
                      },
                    ),
                  )
                else
                  ..._tasks.map((task) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: Icon(
                          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: task.isCompleted ? Colors.green : theme.colorScheme.outline,
                        ),
                        title: Text(task.name,
                            style: TextStyle(
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            )),
                        onTap: () {
                          final id = task.uid ?? task.id?.toString();
                          if (id != null) context.push('/tasks/$id');
                        },
                      )),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
