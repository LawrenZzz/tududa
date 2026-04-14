import 'package:equatable/equatable.dart';

/// Task model matching the tududi backend Task schema.
class Task extends Equatable {
  final int? id;
  final String? uid;
  final String name;
  final String? note;
  final int status;
  final int priority;
  final DateTime? dueDate;
  final DateTime? deferUntil;
  final DateTime? completedAt;
  final int? projectId;
  final int? parentTaskId;
  final int? recurringParentId;
  final int? order;

  // Recurrence fields
  final String recurrenceType;
  final int? recurrenceInterval;
  final DateTime? recurrenceEndDate;
  final int? recurrenceWeekday;
  final List<int>? recurrenceWeekdays;
  final int? recurrenceMonthDay;
  final int? recurrenceWeekOfMonth;
  final bool completionBased;

  // Habit fields
  final bool habitMode;
  final int? habitTargetCount;
  final String? habitFrequencyPeriod;
  final String habitStreakMode;
  final String habitFlexibilityMode;
  final int habitCurrentStreak;
  final int habitBestStreak;
  final int habitTotalCompletions;
  final DateTime? habitLastCompletionAt;

  // Relations (loaded from API)
  final List<Task>? subtasks;
  final List<Tag>? tags;
  final String? projectName;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Task({
    this.id,
    this.uid,
    required this.name,
    this.note,
    this.status = 0,
    this.priority = 0,
    this.dueDate,
    this.deferUntil,
    this.completedAt,
    this.projectId,
    this.parentTaskId,
    this.recurringParentId,
    this.order,
    this.recurrenceType = 'none',
    this.recurrenceInterval,
    this.recurrenceEndDate,
    this.recurrenceWeekday,
    this.recurrenceWeekdays,
    this.recurrenceMonthDay,
    this.recurrenceWeekOfMonth,
    this.completionBased = false,
    this.habitMode = false,
    this.habitTargetCount,
    this.habitFrequencyPeriod,
    this.habitStreakMode = 'calendar',
    this.habitFlexibilityMode = 'flexible',
    this.habitCurrentStreak = 0,
    this.habitBestStreak = 0,
    this.habitTotalCompletions = 0,
    this.habitLastCompletionAt,
    this.subtasks,
    this.tags,
    this.projectName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status == 2;
  bool get isRecurring => recurrenceType != 'none';
  bool get hasSubtasks => subtasks != null && subtasks!.isNotEmpty;

  String get statusName {
    const names = [
      'Not Started', 'In Progress', 'Done', 'Archived',
      'Waiting', 'Cancelled', 'Planned',
    ];
    return (status >= 0 && status < names.length) ? names[status] : 'Unknown';
  }

  String get priorityName {
    const names = ['Low', 'Medium', 'High'];
    return (priority >= 0 && priority < names.length) ? names[priority] : 'Low';
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      uid: json['uid'] as String?,
      name: json['name'] as String? ?? '',
      note: json['note'] as String?,
      status: _parseStatus(json['status']),
      priority: _parsePriority(json['priority']),
      dueDate: _parseDate(json['due_date']),
      deferUntil: _parseDate(json['defer_until']),
      completedAt: _parseDate(json['completed_at']),
      projectId: json['project_id'] as int?,
      parentTaskId: json['parent_task_id'] as int?,
      recurringParentId: json['recurring_parent_id'] as int?,
      order: json['order'] as int?,
      recurrenceType: json['recurrence_type'] as String? ?? 'none',
      recurrenceInterval: json['recurrence_interval'] as int?,
      recurrenceEndDate: _parseDate(json['recurrence_end_date']),
      recurrenceWeekday: json['recurrence_weekday'] as int?,
      recurrenceWeekdays: json['recurrence_weekdays'] != null
          ? List<int>.from(json['recurrence_weekdays'])
          : null,
      recurrenceMonthDay: json['recurrence_month_day'] as int?,
      recurrenceWeekOfMonth: json['recurrence_week_of_month'] as int?,
      completionBased: json['completion_based'] as bool? ?? false,
      habitMode: json['habit_mode'] as bool? ?? false,
      habitTargetCount: json['habit_target_count'] as int?,
      habitFrequencyPeriod: json['habit_frequency_period'] as String?,
      habitStreakMode: json['habit_streak_mode'] as String? ?? 'calendar',
      habitFlexibilityMode: json['habit_flexibility_mode'] as String? ?? 'flexible',
      habitCurrentStreak: json['habit_current_streak'] as int? ?? 0,
      habitBestStreak: json['habit_best_streak'] as int? ?? 0,
      habitTotalCompletions: json['habit_total_completions'] as int? ?? 0,
      habitLastCompletionAt: _parseDate(json['habit_last_completion_at']),
      subtasks: json['Subtasks'] != null
          ? (json['Subtasks'] as List).map((e) => Task.fromJson(e)).toList()
          : null,
      tags: json['Tags'] != null
          ? (json['Tags'] as List).map((e) => Tag.fromJson(e)).toList()
          : null,
      projectName: json['Project'] != null
          ? json['Project']['name'] as String?
          : null,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'status': status,
      'priority': priority,
      'recurrence_type': recurrenceType,
      'completion_based': completionBased,
      'habit_mode': habitMode,
      'habit_streak_mode': habitStreakMode,
      'habit_flexibility_mode': habitFlexibilityMode,
    };
    if (id != null) map['id'] = id;
    if (note != null && note!.isNotEmpty) map['note'] = note;
    if (dueDate != null) map['due_date'] = dueDate!.toIso8601String();
    if (deferUntil != null) map['defer_until'] = deferUntil!.toIso8601String();
    if (projectId != null) map['project_id'] = projectId;
    if (parentTaskId != null) map['parent_task_id'] = parentTaskId;
    if (recurrenceInterval != null) map['recurrence_interval'] = recurrenceInterval;
    if (recurrenceEndDate != null) map['recurrence_end_date'] = recurrenceEndDate!.toIso8601String();
    if (recurrenceWeekday != null) map['recurrence_weekday'] = recurrenceWeekday;
    if (recurrenceWeekdays != null) map['recurrence_weekdays'] = recurrenceWeekdays;
    if (recurrenceMonthDay != null) map['recurrence_month_day'] = recurrenceMonthDay;
    if (recurrenceWeekOfMonth != null) map['recurrence_week_of_month'] = recurrenceWeekOfMonth;
    if (habitTargetCount != null) map['habit_target_count'] = habitTargetCount;
    if (habitFrequencyPeriod != null) map['habit_frequency_period'] = habitFrequencyPeriod;
    return map;
  }

  Task copyWith({
    String? name,
    String? note,
    int? status,
    int? priority,
    DateTime? dueDate,
    DateTime? deferUntil,
    int? projectId,
    String? recurrenceType,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
    int? recurrenceWeekday,
    List<int>? recurrenceWeekdays,
    int? recurrenceMonthDay,
    int? recurrenceWeekOfMonth,
    bool? completionBased,
    bool? habitMode,
    int? habitTargetCount,
    String? habitFrequencyPeriod,
    List<Task>? subtasks,
    List<Tag>? tags,
  }) {
    return Task(
      id: id,
      uid: uid,
      name: name ?? this.name,
      note: note ?? this.note,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      deferUntil: deferUntil ?? this.deferUntil,
      completedAt: completedAt,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId,
      recurringParentId: recurringParentId,
      order: order,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      recurrenceWeekday: recurrenceWeekday ?? this.recurrenceWeekday,
      recurrenceWeekdays: recurrenceWeekdays ?? this.recurrenceWeekdays,
      recurrenceMonthDay: recurrenceMonthDay ?? this.recurrenceMonthDay,
      recurrenceWeekOfMonth: recurrenceWeekOfMonth ?? this.recurrenceWeekOfMonth,
      completionBased: completionBased ?? this.completionBased,
      habitMode: habitMode ?? this.habitMode,
      habitTargetCount: habitTargetCount ?? this.habitTargetCount,
      habitFrequencyPeriod: habitFrequencyPeriod ?? this.habitFrequencyPeriod,
      habitStreakMode: habitStreakMode,
      habitFlexibilityMode: habitFlexibilityMode,
      habitCurrentStreak: habitCurrentStreak,
      habitBestStreak: habitBestStreak,
      habitTotalCompletions: habitTotalCompletions,
      habitLastCompletionAt: habitLastCompletionAt,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      projectName: projectName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static int _parseStatus(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      const map = {
        'not_started': 0, 'in_progress': 1, 'done': 2,
        'archived': 3, 'waiting': 4, 'cancelled': 5, 'planned': 6,
      };
      return map[value] ?? 0;
    }
    return 0;
  }

  static int _parsePriority(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      const map = {'low': 0, 'medium': 1, 'high': 2};
      return map[value] ?? 0;
    }
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [id, uid];
}

/// Tag model - simplified for inline use
class Tag extends Equatable {
  final int? id;
  final String? uid;
  final String name;
  final DateTime? createdAt;

  const Tag({
    this.id,
    this.uid,
    required this.name,
    this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int?,
      uid: json['uid'] as String?,
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
  };

  @override
  List<Object?> get props => [id, name];
}
