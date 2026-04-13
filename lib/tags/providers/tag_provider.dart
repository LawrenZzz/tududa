import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag_model.dart';
import '../../core/services/api_service.dart';

class TagListState {
  final List<Tag> tags;
  final bool isLoading;
  final String? error;

  const TagListState({this.tags = const [], this.isLoading = false, this.error});

  TagListState copyWith({List<Tag>? tags, bool? isLoading, String? error}) {
    return TagListState(
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TagNotifier extends StateNotifier<TagListState> {
  TagNotifier() : super(const TagListState());

  Future<void> loadTags() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await ApiService.instance.getTags();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['tags'] ?? []);
        final tags = data.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(tags: tags, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed');
      }
    } catch (e) {
      debugPrint('Load tags error: $e');
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  Future<bool> createTag(String name) async {
    try {
      final response = await ApiService.instance.createTag({'name': name});
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadTags();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTag(int id) async {
    try {
      final response = await ApiService.instance.deleteTag(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await loadTags();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final tagListProvider = StateNotifierProvider<TagNotifier, TagListState>((ref) {
  return TagNotifier();
});
