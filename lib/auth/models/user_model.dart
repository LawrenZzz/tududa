import 'package:equatable/equatable.dart';

/// User model matching the tududi backend User schema.
class User extends Equatable {
  final int? id;
  final String uid;
  final String? name;
  final String? surname;
  final String email;
  final String appearance;
  final String language;
  final String timezone;
  final int firstDayOfWeek;
  final String? avatarImage;
  final String? telegramBotToken;
  final String? telegramChatId;
  final bool taskSummaryEnabled;
  final String? taskSummaryFrequency;
  final bool pomodoroEnabled;
  final Map<String, dynamic>? todaySettings;
  final Map<String, dynamic>? sidebarSettings;
  final Map<String, dynamic>? uiSettings;
  final Map<String, dynamic>? notificationPreferences;

  const User({
    this.id,
    required this.uid,
    this.name,
    this.surname,
    required this.email,
    this.appearance = 'light',
    this.language = 'en',
    this.timezone = 'UTC',
    this.firstDayOfWeek = 1,
    this.avatarImage,
    this.telegramBotToken,
    this.telegramChatId,
    this.taskSummaryEnabled = false,
    this.taskSummaryFrequency,
    this.pomodoroEnabled = true,
    this.todaySettings,
    this.sidebarSettings,
    this.uiSettings,
    this.notificationPreferences,
  });

  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return surname != null && surname!.isNotEmpty
          ? '$name $surname'
          : name!;
    }
    return email;
  }

  String get initials {
    if (name != null && name!.isNotEmpty) {
      final first = name![0].toUpperCase();
      if (surname != null && surname!.isNotEmpty) {
        return '$first${surname![0].toUpperCase()}';
      }
      return first;
    }
    return email[0].toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      email: json['email'] as String,
      appearance: json['appearance'] as String? ?? 'light',
      language: json['language'] as String? ?? 'en',
      timezone: json['timezone'] as String? ?? 'UTC',
      firstDayOfWeek: json['first_day_of_week'] as int? ?? 1,
      avatarImage: json['avatar_image'] as String?,
      telegramBotToken: json['telegram_bot_token'] as String?,
      telegramChatId: json['telegram_chat_id'] as String?,
      taskSummaryEnabled: json['task_summary_enabled'] as bool? ?? false,
      taskSummaryFrequency: json['task_summary_frequency'] as String?,
      pomodoroEnabled: json['pomodoro_enabled'] as bool? ?? true,
      todaySettings: json['today_settings'] as Map<String, dynamic>?,
      sidebarSettings: json['sidebar_settings'] as Map<String, dynamic>?,
      uiSettings: json['ui_settings'] as Map<String, dynamic>?,
      notificationPreferences: json['notification_preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'surname': surname,
      'email': email,
      'appearance': appearance,
      'language': language,
      'timezone': timezone,
      'first_day_of_week': firstDayOfWeek,
      'avatar_image': avatarImage,
      'telegram_bot_token': telegramBotToken,
      'telegram_chat_id': telegramChatId,
      'task_summary_enabled': taskSummaryEnabled,
      'task_summary_frequency': taskSummaryFrequency,
      'pomodoro_enabled': pomodoroEnabled,
      'today_settings': todaySettings,
      'sidebar_settings': sidebarSettings,
      'ui_settings': uiSettings,
      'notification_preferences': notificationPreferences,
    };
  }

  User copyWith({
    String? name,
    String? surname,
    String? appearance,
    String? language,
    String? timezone,
    int? firstDayOfWeek,
    String? avatarImage,
    String? telegramBotToken,
    String? telegramChatId,
    bool? taskSummaryEnabled,
    String? taskSummaryFrequency,
    bool? pomodoroEnabled,
    Map<String, dynamic>? todaySettings,
    Map<String, dynamic>? sidebarSettings,
    Map<String, dynamic>? uiSettings,
    Map<String, dynamic>? notificationPreferences,
  }) {
    return User(
      id: id,
      uid: uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email,
      appearance: appearance ?? this.appearance,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      avatarImage: avatarImage ?? this.avatarImage,
      telegramBotToken: telegramBotToken ?? this.telegramBotToken,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      taskSummaryEnabled: taskSummaryEnabled ?? this.taskSummaryEnabled,
      taskSummaryFrequency: taskSummaryFrequency ?? this.taskSummaryFrequency,
      pomodoroEnabled: pomodoroEnabled ?? this.pomodoroEnabled,
      todaySettings: todaySettings ?? this.todaySettings,
      sidebarSettings: sidebarSettings ?? this.sidebarSettings,
      uiSettings: uiSettings ?? this.uiSettings,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
    );
  }

  @override
  List<Object?> get props => [id, uid, email];
}
