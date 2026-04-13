import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../../l10n/strings.dart';
import '../../core/services/api_service.dart';

/// Note editor screen (create/edit) with Markdown support.
class NoteEditorScreen extends ConsumerStatefulWidget {
  final dynamic noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int? _projectId;
  String? _color;
  bool _isLoading = false;
  bool _isEdit = false;

  static const _colors = [
    null,
    '#FFD6D6',
    '#FFE4CC',
    '#FFF3CC',
    '#D6FFD6',
    '#CCE5FF',
    '#E8CCFF',
    '#FFCCE5',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      _isEdit = true;
      _loadNote();
    }
    Future.microtask(() => ref.read(projectListProvider.notifier).loadProjects());
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.instance.getNote(widget.noteId!);
      if (response.statusCode == 200 && mounted) {
        final data = response.data is Map<String, dynamic>
            ? response.data
            : response.data['note'];
        if (data != null) {
          final note = Note.fromJson(data as Map<String, dynamic>);
          _titleController.text = note.title ?? '';
          _contentController.text = note.content ?? '';
          setState(() {
            _projectId = note.projectId;
            _color = note.color;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    final note = Note(
      uid: widget.noteId is String ? widget.noteId : null,
      id: widget.noteId is int ? widget.noteId : null,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      content: _contentController.text.trim(),
      projectId: _projectId,
      color: _color,
    );

    bool success;
    if (_isEdit) {
      success = await ref.read(noteListProvider.notifier).updateNote(note);
    } else {
      success = await ref.read(noteListProvider.notifier).createNote(note);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save note')),
        );
      }
    }
  }

  Future<void> _delete() async {
    if (widget.noteId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(noteListProvider.notifier).deleteNote(widget.noteId!);
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectState = ref.watch(projectListProvider);
    final strings = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? strings.editNote : strings.newNote),
        actions: [
          if (_isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: _delete,
            ),
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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  autofocus: !_isEdit,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.titleLarge,
                  decoration: InputDecoration(
                    hintText: strings.noteTitle,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: false,
                    hintStyle: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                const Divider(),

                // Content
                TextFormField(
                  controller: _contentController,
                  maxLines: null,
                  minLines: 12,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: strings.contentHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: false,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),

                const Divider(height: 32),

                // Color picker
                Text(strings.color, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _colors.map((c) {
                    final isSelected = _color == c;
                    final displayColor = c != null
                        ? Color(int.parse('FF${c.replaceFirst('#', '')}', radix: 16))
                        : theme.colorScheme.surface;
                    return GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: displayColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: c == null
                            ? Icon(Icons.format_color_reset, size: 16, color: theme.colorScheme.onSurfaceVariant)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Project
                DropdownButtonFormField<int?>(
                  initialValue: _projectId,
                  decoration: InputDecoration(
                    labelText: strings.project,
                    prefixIcon: const Icon(Icons.folder_outlined),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(strings.none)),
                    ...projectState.projects.map((p) =>
                        DropdownMenuItem(value: p.id, child: Text(p.name))),
                  ],
                  onChanged: (v) => setState(() => _projectId = v),
                ),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
