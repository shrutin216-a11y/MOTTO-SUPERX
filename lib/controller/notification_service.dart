import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Notification received: ${message.notification?.title}');
      if (message.notification != null) {
        showNotification(
          message.notification!.title ?? 'New Trip Posted!',
          message.notification!.body ?? '',
        );
      }
    });

    // Get token for testing
    String? token = await _firebaseMessaging.getToken();
    log("Device Token: $token");
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'trip_channel',
      'Trip Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(0, title, body, details);
  }
}
