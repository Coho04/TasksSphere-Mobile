import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'api_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static final StreamController<RemoteMessage> _onMessageStreamController = StreamController<RemoteMessage>.broadcast();
  static Stream<RemoteMessage> get onMessageStream => _onMessageStreamController.stream;

  static bool get _isSupported {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  static Future<void> initialize() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    if (!_isSupported) {
      debugPrint("Firebase Messaging is not supported on this platform.");
      return;
    }

    // Request permissions (especially for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Get FCM Token
    String? token = await _fcm.getToken();
    debugPrint("FCM Token: $token");

    // Listen to token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token refreshed: $newToken");
      updateTokenOnServer(newToken);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');
      
      _onMessageStreamController.add(message);

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification?.title}');
        _showLocalNotification(message);
      }
    });

    // Handle when app is in background but opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification: ${message.data}');
      _onMessageStreamController.add(message);
    });
  }

  static Future<void> updateTokenOnServer([String? token]) async {
    if (!_isSupported) return;
    String? fcmToken = token ?? await _fcm.getToken();
    if (fcmToken != null) {
      final apiService = ApiService();
      try {
        // Dieser Endpoint muss in Laravel existieren
        await apiService.dio.post('/user/fcm-token', data: {'fcm_token': fcmToken});
        debugPrint("FCM Token updated on server");
      } catch (e) {
        debugPrint("Error updating FCM token on server: $e (This is expected if the endpoint is not yet implemented)");
      }
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'taskssphere_channel_id',
      'Tasks Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint("Handling a background message: ${message.messageId}");
  }
}
