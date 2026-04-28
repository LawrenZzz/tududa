/// Application-wide constants for the Tududi app.
class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'Tududi';
  static const String appVersion = '1.0.1';

  // API
  static const String apiVersion = 'v1';
  static const String apiBasePath = '/api/$apiVersion';

  // Storage Keys
  static const String serverUrlKey = 'server_url';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String cookieKey = 'cookies';

  // Task Status (matches backend integer values)
  static const int taskStatusNotStarted = 0;
  static const int taskStatusInProgress = 1;
  static const int taskStatusDone = 2;
  static const int taskStatusArchived = 3;
  static const int taskStatusWaiting = 4;
  static const int taskStatusCancelled = 5;
  static const int taskStatusPlanned = 6;

  // Task Priority
  static const int taskPriorityLow = 0;
  static const int taskPriorityMedium = 1;
  static const int taskPriorityHigh = 2;

  // Recurrence Type
  static const String recurrenceNone = 'none';
  static const String recurrenceDaily = 'daily';
  static const String recurrenceWeekly = 'weekly';
  static const String recurrenceMonthly = 'monthly';
  static const String recurrenceMonthlyWeekday = 'monthly_weekday';
  static const String recurrenceMonthlyLastDay = 'monthly_last_day';

  // Project Status
  static const String projectNotStarted = 'not_started';
  static const String projectInProgress = 'in_progress';
  static const String projectDone = 'done';
  static const String projectWaiting = 'waiting';
  static const String projectCancelled = 'cancelled';
  static const String projectPlanned = 'planned';

  // Inbox Item Status
  static const String inboxAdded = 'added';
  static const String inboxProcessed = 'processed';
  static const String inboxIgnored = 'ignored';
}

/// Extension to get display names for task status
extension TaskStatusExtension on int {
  String get taskStatusName {
    switch (this) {
      case 0:
        return 'Not Started';
      case 1:
        return 'In Progress';
      case 2:
        return 'Done';
      case 3:
        return 'Archived';
      case 4:
        return 'Waiting';
      case 5:
        return 'Cancelled';
      case 6:
        return 'Planned';
      default:
        return 'Unknown';
    }
  }

  String get taskPriorityName {
    switch (this) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Low';
    }
  }
}
