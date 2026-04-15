import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// Top-level — must be outside any class, required by FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 [FCM] Background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs =
  FlutterLocalNotificationsPlugin();

  static const _channelId = 'roadsense_alerts';
  static const _channelName = 'RoadSense Alerts';
  static const _channelDesc = 'Flood and temperature alerts from your device';

  Future<void> init() async {
    // 1. Request permission (shows system dialog on Android 13+ and iOS)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔔 FCM permission: ${settings.authorizationStatus}');

    // 2. Init local notifications plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifs.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // 3. Create the Android notification channel
    // FIX: correct generic syntax <AndroidFlutterLocalNotificationsPlugin>
    await _localNotifs
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
      ),
    );

    // 4. Show local notif when FCM arrives while app is FOREGROUND
    // (FCM does NOT auto-show heads-up when app is open — we do it manually)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 [FCM] Foreground message: ${message.notification?.title}');
      _showLocalNotification(
        title: message.notification?.title ?? 'RoadSense Alert',
        body: message.notification?.body ?? '',
      );
    });

    // 5. Background handler is registered in main() before runApp, not here
    // (calling it here a second time is harmless but redundant)

    // 6. Log token — actual saving to DB is done from AppShell after auth
    final token = await _fcm.getToken();
    debugPrint('🔑 FCM Token: $token');

    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      // Token refresh saving is handled by AppShell via getToken()
    });
  }

  /// Called from _checkAlerts() in AppShell when a threshold is crossed
  Future<void> showAlert({
    required String title,
    required String body,
    bool isCritical = false,
  }) async {
    await _showLocalNotification(title: title, body: body, isCritical: isCritical);
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    bool isCritical = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: isCritical ? Importance.max : Importance.high,
      priority: isCritical ? Priority.max : Priority.high,
      icon: '@mipmap/ic_launcher',
      color: isCritical ? const Color(0xFFEF4444) : const Color(0xFFD4A017),
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifs.show(
      // Use truncated milliseconds as unique ID (int32 safe)
      DateTime.now().millisecondsSinceEpoch ~/ 1000 % 2147483647,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<String?> getToken() => _fcm.getToken();
}