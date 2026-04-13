import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/area_model.dart';
import '../../core/services/api_service.dart';

class AreaListState {
  final List<Area> areas;
  final bool isLoading;
  final String? error;

  const AreaListState({this.areas = const [], this.isLoading = false, this.error});

  AreaListState copyWith({List<Area>? areas, bool? isLoading, String? error}) {
    return AreaListState(
      areas: areas ?? this.areas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AreaNotifier extends StateNotifier<AreaListState> {
  AreaNotifier() : super(const AreaListState());

  Future<void> loadAreas() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await ApiService.instance.getAreas();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['areas'] ?? []);
        final areas = data.map((e) => Area.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(areas: areas, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load areas');
      }
    } catch (e) {
      debugPrint('Load areas error: $e');
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  Future<bool> createArea(Area area) async {
    try {
      final response = await ApiService.instance.createArea(area.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadAreas();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateArea(Area area) async {
    try {
      if (area.id == null) return false;
      final response = await ApiService.instance.updateArea(area.id!, area.toJson());
      if (response.statusCode == 200) {
        await loadAreas();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteArea(int id) async {
    try {
      final response = await ApiService.instance.deleteArea(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await loadAreas();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final areaListProvider = StateNotifierProvider<AreaNotifier, AreaListState>((ref) {
  return AreaNotifier();
});
