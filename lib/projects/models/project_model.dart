import 'package:equatable/equatable.dart';

/// Project model matching the tududi backend Project schema.
class Project extends Equatable {
  final int? id;
  final String? uid;
  final String name;
  final String? description;
  final String status;
  final String? priority;
  final DateTime? dueDateAt;
  final int? areaId;
  final String? imageUrl;
  final bool pinToSidebar;
  final bool taskShowCompleted;
  final String taskSortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relations
  final String? areaName;
  final int? taskCount;
  final int? completedTaskCount;

  const Project({
    this.id,
    this.uid,
    required this.name,
    this.description,
    this.status = 'not_started',
    this.priority,
    this.dueDateAt,
    this.areaId,
    this.imageUrl,
    this.pinToSidebar = false,
    this.taskShowCompleted = false,
    this.taskSortOrder = 'created_at:desc',
    this.createdAt,
    this.updatedAt,
    this.areaName,
    this.taskCount,
    this.completedTaskCount,
  });

  double get progress {
    if (taskCount == null || taskCount == 0) return 0;
    return (completedTaskCount ?? 0) / taskCount!;
  }

  String get statusDisplay {
    switch (status) {
      case 'not_started':
        return 'Not Started';
      case 'in_progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      case 'waiting':
        return 'Waiting';
      case 'cancelled':
        return 'Cancelled';
      case 'planned':
        return 'Planned';
      default:
        return status;
    }
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int?,
      uid: json['uid'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'not_started',
      priority: json['priority'] as String?,
      dueDateAt: json['due_date_at'] != null
          ? DateTime.tryParse(json['due_date_at'].toString())
          : null,
      areaId: json['area_id'] as int?,
      imageUrl: json['image_url'] as String?,
      pinToSidebar: json['pin_to_sidebar'] as bool? ?? false,
      taskShowCompleted: json['task_show_completed'] as bool? ?? false,
      taskSortOrder: json['task_sort_order'] as String? ?? 'created_at:desc',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null),
      areaName: json['Area'] != null ? json['Area']['name'] as String? : null,
      taskCount: _parseTaskCount(json),
      completedTaskCount: _parseCompletedCount(json),
    );
  }

  static int? _parseTaskCount(Map<String, dynamic> json) {
    if (json['task_status'] is Map) {
      return (json['task_status']['total'] as num?)?.toInt();
    }
    return (json['taskCount'] as num?)?.toInt();
  }

  static int? _parseCompletedCount(Map<String, dynamic> json) {
    if (json['task_status'] is Map) {
      return (json['task_status']['done'] as num?)?.toInt();
    }
    return (json['completedTaskCount'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date_at': dueDateAt?.toIso8601String(),
      'area_id': areaId,
      'image_url': imageUrl,
      'pin_to_sidebar': pinToSidebar,
      'task_show_completed': taskShowCompleted,
      'task_sort_order': taskSortOrder,
    };
  }

  Project copyWith({
    String? name,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDateAt,
    int? areaId,
    String? imageUrl,
    bool? pinToSidebar,
    bool? taskShowCompleted,
    String? taskSortOrder,
  }) {
    return Project(
      id: id,
      uid: uid,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDateAt: dueDateAt ?? this.dueDateAt,
      areaId: areaId ?? this.areaId,
      imageUrl: imageUrl ?? this.imageUrl,
      pinToSidebar: pinToSidebar ?? this.pinToSidebar,
      taskShowCompleted: taskShowCompleted ?? this.taskShowCompleted,
      taskSortOrder: taskSortOrder ?? this.taskSortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      areaName: areaName,
      taskCount: taskCount,
      completedTaskCount: completedTaskCount,
    );
  }

  @override
  List<Object?> get props => [id, uid];
}
