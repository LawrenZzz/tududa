import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import '../../areas/providers/area_provider.dart';
import '../../l10n/strings.dart';

/// Project create/edit form.
class ProjectFormScreen extends ConsumerStatefulWidget {
  final dynamic projectId;
  const ProjectFormScreen({super.key, this.projectId});

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _status = 'not_started';
  String? _priority;
  int? _areaId;
  bool _pinToSidebar = false;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _isEdit = true;
      _loadProject();
    }
    Future.microtask(() => ref.read(areaListProvider.notifier).loadAreas());
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    final project = await ref.read(projectDetailProvider(widget.projectId!).future);
    if (project != null && mounted) {
      _nameController.text = project.name;
      _descController.text = project.description ?? '';
      setState(() {
        _status = project.status;
        _priority = project.priority;
        _areaId = project.areaId;
        _pinToSidebar = project.pinToSidebar;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final project = Project(
      uid: widget.projectId is String ? widget.projectId : null,
      id: widget.projectId is int ? widget.projectId : null,
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      status: _status,
      priority: _priority,
      areaId: _areaId,
      pinToSidebar: _pinToSidebar,
    );

    bool success;
    if (_isEdit) {
      success = await ref.read(projectListProvider.notifier).updateProject(project);
    } else {
      success = await ref.read(projectListProvider.notifier).createProject(project);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save project')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final areaState = ref.watch(areaListProvider);
    final strings = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? strings.editProject : strings.newProject),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
                  TextFormField(
                    controller: _nameController,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: strings.projectName,
                      hintText: strings.projectNameHint,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return strings.nameRequired;
                      if (v.trim().split(RegExp(r'\s+')).length > 6) {
                        return strings.projectNameHint;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: strings.desc,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status
                  Text(strings.status, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.flag_outlined)),
                    items: [
                      DropdownMenuItem(value: 'not_started', child: Text(strings.notStarted)),
                      DropdownMenuItem(value: 'planned', child: Text(strings.planned)),
                      DropdownMenuItem(value: 'in_progress', child: Text(strings.inProgress)),
                      DropdownMenuItem(value: 'waiting', child: Text(strings.waiting)),
                      DropdownMenuItem(value: 'done', child: Text(strings.done)),
                      DropdownMenuItem(value: 'cancelled', child: Text(strings.cancelled)),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'not_started'),
                  ),
                  const SizedBox(height: 16),

                  // Priority
                  Text(strings.priority, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<String?>(
                    segments: [
                      ButtonSegment(value: null, label: Text(strings.none)),
                      ButtonSegment(value: 'low', label: Text(strings.low)),
                      ButtonSegment(value: 'medium', label: Text(strings.medium)),
                      ButtonSegment(value: 'high', label: Text(strings.high)),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (v) => setState(() => _priority = v.first),
                  ),
                  const SizedBox(height: 16),

                  // Area
                  DropdownButtonFormField<int?>(
                    initialValue: _areaId,
                    decoration: InputDecoration(
                      labelText: strings.area,
                      prefixIcon: const Icon(Icons.layers_outlined),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(strings.noArea)),
                      ...areaState.areas.map((a) =>
                          DropdownMenuItem(value: a.id, child: Text(a.name))),
                    ],
                    onChanged: (v) => setState(() => _areaId = v),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.pinSidebar),
                    subtitle: Text(strings.pinSidebarHint),
                    value: _pinToSidebar,
                    onChanged: (v) => setState(() => _pinToSidebar = v),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
