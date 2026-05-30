import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Android Channel setup
  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'quiz_channel', // id
    'Daily Quizzes', // name
    description: 'Notifications for daily quizzes and updates', // description
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> init() async {
    // 1. Request Permissions (iOS / Android 13+ / Web)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // Web-specific initialization skip for local notifications
    if (kIsWeb) {
      debugPrint('Skipping local notification init on Web');
      _setupForegroundHandler();
      return;
    }

    // 2. Initialize Local Notifications (Mobile Only)
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint("Notification Tapped: ${details.payload}");
        },
      );

      // 3. Android Specific: Create Channel
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(_androidChannel);
    } catch (e) {
      debugPrint("Local Notifications Init Failed (expected on some platforms): $e");
    }

    _setupForegroundHandler();
    _setupTokenAndTopic();
  }

  static void _setupForegroundHandler() {
    // 4. Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');

      if (message.notification != null && !kIsWeb) {
        RemoteNotification? notification = message.notification;
        
        if (notification != null) {
          _notificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(),
            ),
          );
        }
      }
    });

    // 5. Background/Terminated Tap Handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Message clicked!");
    });

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _setupTokenAndTopic() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: $token");
      await _firebaseMessaging.subscribeToTopic('all');
    } catch (e) {
      debugPrint("FCM Topic Subscription Failed: $e");
    }
  }
  static Future<void> subscribeToUserTopic(String userId) async {
    try {
      await _firebaseMessaging.subscribeToTopic('user_$userId');
      debugPrint("Subscribed to user topic: user_$userId");
    } catch (e) {
      debugPrint("Failed to subscribe to user topic: $e");
    }
  }

  static Future<void> unsubscribeFromUserTopic(String userId) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('user_$userId');
      debugPrint("Unsubscribed from user topic: user_$userId");
    } catch (e) {
      debugPrint("Failed to unsubscribe from user topic: $e");
    }
  }
}
