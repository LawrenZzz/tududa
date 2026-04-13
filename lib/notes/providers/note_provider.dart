import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../../core/services/api_service.dart';

class NoteListState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;

  const NoteListState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NoteListState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
  }) {
    return NoteListState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NoteNotifier extends StateNotifier<NoteListState> {
  NoteNotifier() : super(const NoteListState());

  Future<void> loadNotes({dynamic projectId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final queryParams = <String, dynamic>{};
      if (projectId != null) queryParams['project_id'] = projectId;

      final response = await ApiService.instance.getNotes(queryParams: queryParams);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['notes'] ?? []);
        final notes = data
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(notes: notes, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load notes');
      }
    } catch (e) {
      debugPrint('Load notes error: $e');
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  Future<bool> createNote(Note note) async {
    try {
      final response = await ApiService.instance.createNote(note.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadNotes();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNote(Note note) async {
    try {
      if (note.id == null) return false;
      final response = await ApiService.instance.updateNote(note.id!, note.toJson());
      if (response.statusCode == 200) {
        await loadNotes();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNote(dynamic id) async {
    try {
      final response = await ApiService.instance.deleteNote(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await loadNotes();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final noteListProvider =
    StateNotifierProvider<NoteNotifier, NoteListState>((ref) {
  return NoteNotifier();
});
