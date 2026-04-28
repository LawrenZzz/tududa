import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../../l10n/strings.dart';

/// Task create/edit form screen.
class TaskFormScreen extends ConsumerStatefulWidget {
  final dynamic taskId;
  final int? defaultProjectId;
  const TaskFormScreen({super.key, this.taskId, this.defaultProjectId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  int _priority = 0;
  int _status = 0;
  DateTime? _dueDate;
  DateTime? _deferUntil;
  int? _projectId;
  String _recurrenceType = 'none';
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;
  bool _completionBased = false;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _isEdit = true;
      _loadTask();
    } else if (widget.defaultProjectId != null) {
      _projectId = widget.defaultProjectId;
    }
    // Ensure projects are loaded for the picker
    Future.microtask(
        () => ref.read(projectListProvider.notifier).loadProjects());
  }

  // Store the actual numeric id and uid from the loaded task
  int? _loadedTaskId;
  String? _loadedTaskUid;

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);
    final task = await ref.read(taskDetailProvider(widget.taskId!).future);
    if (task != null && mounted) {
      _nameController.text = task.name;
      _noteController.text = task.note ?? '';
      setState(() {
        _loadedTaskId = task.id;
        _loadedTaskUid = task.uid;
        _priority = task.priority;
        _status = task.status;
        _dueDate = task.dueDate;
        _deferUntil = task.deferUntil;
        _projectId = task.projectId;
        _recurrenceType = task.recurrenceType;
        _recurrenceInterval = task.recurrenceInterval ?? 1;
        _recurrenceEndDate = task.recurrenceEndDate;
        _completionBased = task.completionBased;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final task = Task(
      id: _loadedTaskId,
      uid: _loadedTaskUid,
      name: _nameController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      priority: _priority,
      status: _status,
      dueDate: _dueDate,
      deferUntil: _deferUntil,
      projectId: _projectId,
      recurrenceType: _recurrenceType,
      recurrenceInterval: _recurrenceType != 'none' ? _recurrenceInterval : null,
      recurrenceEndDate: _recurrenceEndDate,
      completionBased: _completionBased,
    );

    bool success;
    if (_isEdit) {
      success = await ref.read(taskListProvider.notifier).updateTask(task);
    } else {
      success = await ref.read(taskListProvider.notifier).createTask(task);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (_isEdit && widget.taskId != null) {
          ref.invalidate(taskDetailProvider(widget.taskId!));
        }
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save task')),
        );
      }
    }
  }

  Future<void> _pickDate({required bool isDueDate}) async {
    final initial = isDueDate ? _dueDate : _deferUntil;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _deferUntil = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectState = ref.watch(projectListProvider);
    final strings = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? strings.editTask : strings.newTask),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(strings.save),
          ),
        ],
      ),
      body: _isLoading && _isEdit
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Name
                  TextFormField(
                    controller: _nameController,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: strings.taskName,
                      hintText: strings.taskNameHint,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? strings.nameRequired : null,
                  ),
                  const SizedBox(height: 16),

                  // Priority
                  Text(strings.priority, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 0, label: Text(strings.low), icon: const Icon(Icons.arrow_downward, size: 16)),
                      ButtonSegment(value: 1, label: Text(strings.medium), icon: const Icon(Icons.remove, size: 16)),
                      ButtonSegment(value: 2, label: Text(strings.high), icon: const Icon(Icons.arrow_upward, size: 16)),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (v) => setState(() => _priority = v.first),
                  ),
                  const SizedBox(height: 20),

                  // Status
                  Text(strings.status, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    key: ValueKey(_status),
                    initialValue: _status,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.radio_button_checked_outlined),
                    ),
                    items: _statusOptions(strings)
                        .map(
                          (option) => DropdownMenuItem<int>(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Due Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text(strings.dueDate),
                    subtitle: Text(
                      _dueDate != null
                          ? DateFormat.yMMMd().format(_dueDate!)
                          : strings.notSet,
                    ),
                    trailing: _dueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _dueDate = null),
                          )
                        : null,
                    onTap: () => _pickDate(isDueDate: true),
                  ),

                  // Defer Until
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule_outlined),
                    title: Text(strings.deferUntil),
                    subtitle: Text(
                      _deferUntil != null
                          ? DateFormat.yMMMd().format(_deferUntil!)
                          : strings.notSet,
                    ),
                    trailing: _deferUntil != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _deferUntil = null),
                          )
                        : null,
                    onTap: () => _pickDate(isDueDate: false),
                  ),

                  const Divider(height: 32),

                  // Project
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(strings.project),
                    subtitle: Text(
                      _projectId != null
                          ? projectState.projects
                                  .where((p) => p.id == _projectId)
                                  .firstOrNull
                                  ?.name ??
                              'Selected'
                          : strings.none,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showProjectPicker(strings),
                  ),

                  const Divider(height: 32),

                  // Recurrence
                  Text(strings.recurrence, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _recurrenceType,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    items: [
                      DropdownMenuItem(value: 'none', child: Text(strings.none)),
                      DropdownMenuItem(value: 'daily', child: Text(strings.daily)),
                      DropdownMenuItem(value: 'weekly', child: Text(strings.weekly)),
                      DropdownMenuItem(value: 'monthly', child: Text(strings.monthly)),
                      DropdownMenuItem(value: 'monthly_weekday', child: Text('${strings.monthly} (Weekday)')),
                      DropdownMenuItem(value: 'monthly_last_day', child: Text('${strings.monthly} (Last Day)')),
                    ],
                    onChanged: (v) => setState(() => _recurrenceType = v ?? 'none'),
                  ),

                  if (_recurrenceType != 'none') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(strings.isZh ? '每 ' : 'Every '),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: '$_recurrenceInterval',
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null && n > 0) _recurrenceInterval = n;
                            },
                          ),
                        ),
                        Text(' ${_recurrenceUnitLabel(strings)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(strings.isZh ? '基于完成状态' : 'Completion-based'),
                      subtitle: Text(strings.isZh ? '从上次完成时间开始循环' : 'Repeat from completion date'),
                      value: _completionBased,
                      onChanged: (v) => setState(() => _completionBased = v),
                    ),
                  ],

                  const Divider(height: 32),

                  // Note
                  TextFormField(
                    controller: _noteController,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: strings.noteDetail,
                      hintText: strings.noteHint,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  String _recurrenceUnitLabel(AppStrings strings) {
    switch (_recurrenceType) {
      case 'daily':
        return strings.isZh ? '天' : (_recurrenceInterval == 1 ? 'day' : 'days');
      case 'weekly':
        return strings.isZh ? '周' : (_recurrenceInterval == 1 ? 'week' : 'weeks');
      default:
        return strings.isZh ? '月' : (_recurrenceInterval == 1 ? 'month' : 'months');
    }
  }

  List<({int value, String label})> _statusOptions(AppStrings strings) {
    return [
      (value: 0, label: strings.notStarted),
      (value: 6, label: strings.planned),
      (value: 1, label: strings.inProgress),
      (value: 4, label: strings.waiting),
      (value: 5, label: strings.cancelled),
      (value: 2, label: strings.done),
    ];
  }

  void _showProjectPicker(AppStrings strings) {
    final projectState = ref.read(projectListProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.clear),
            title: Text(strings.none),
            onTap: () {
              setState(() => _projectId = null);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ...projectState.projects.map((p) => ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(p.name),
                trailing: p.id == _projectId
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() => _projectId = p.id);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
