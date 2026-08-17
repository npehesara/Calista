import '../models/app_notification.dart';

class NotificationStore {
  static final List<AppNotification> _notifications = [];

  static List<AppNotification> getAll() {
    return _notifications.reversed.toList();
  }

  static void add(String title, String message) {
    _notifications.add(
      AppNotification(title: title, message: message, time: DateTime.now()),
    );
  }

  static void clear() {
    _notifications.clear();
  }
}
