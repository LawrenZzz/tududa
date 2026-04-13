import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inbox_item_model.dart';
import '../../core/services/api_service.dart';

class InboxState {
  final List<InboxItem> items;
  final bool isLoading;
  final String? error;

  const InboxState({this.items = const [], this.isLoading = false, this.error});

  InboxState copyWith({List<InboxItem>? items, bool? isLoading, String? error}) {
    return InboxState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InboxNotifier extends StateNotifier<InboxState> {
  InboxNotifier() : super(const InboxState());

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await ApiService.instance.getInboxItems();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['inboxItems'] ?? response.data['inbox_items'] ?? []);
        final items = data.map((e) => InboxItem.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(items: items, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed');
      }
    } catch (e) {
      debugPrint('Load inbox error: $e');
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  Future<bool> processItem(int id) async {
    try {
      final response = await ApiService.instance.updateInboxItem(id, {'status': 'processed'});
      if (response.statusCode == 200) {
        await loadItems();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> ignoreItem(int id) async {
    try {
      final response = await ApiService.instance.updateInboxItem(id, {'status': 'ignored'});
      if (response.statusCode == 200) {
        await loadItems();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      final response = await ApiService.instance.deleteInboxItem(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await loadItems();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final inboxProvider = StateNotifierProvider<InboxNotifier, InboxState>((ref) {
  return InboxNotifier();
});
