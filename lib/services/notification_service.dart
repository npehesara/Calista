import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_store.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 🔐 permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 🔥 token
    String? token = await _messaging.getToken();
    print("FCM TOKEN: $token");

    // 📡 topic
    await _messaging.subscribeToTopic("calista");

    // ================= LOCAL NOTIFICATION =================
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    // ✅ FIX: named parameter required
    await _localNotifications.initialize(
      settings: initSettings,
    );

    // foreground
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // open app from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    final title = message.notification?.title ?? "Calista Alert";
    final body = message.notification?.body ?? "New Notification";

    NotificationStore.add(title, body);

    showNotification(title, body);
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'calista_channel',
      'Calista Notifications',
      channelDescription: 'IoT alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    // ✅ FIX: named parameters required
    await _localNotifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}