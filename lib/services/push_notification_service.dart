import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'api_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final StreamController<RemoteMessage> _onMessageStreamController = StreamController<RemoteMessage>.broadcast();
  static Stream<RemoteMessage> get onMessageStream => _onMessageStreamController.stream;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'taskssphere_channel_id', // id
    'Tasks Notifications', // title
    description: 'This channel is used for task notifications.', // description
    importance: Importance.max,
  );

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

    // iOS and macOS initialization settings
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Create Android Notification Channel
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

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

    // Set foreground notification options for iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen to token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token refreshed: $newToken");
      updateTokenOnServer(newToken);
    });

    // Get FCM Token
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        // Auf iOS/macOS warten wir kurz auf den APNS-Token
        for (int i = 0; i < 6; i++) {
          String? apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null) {
            String? token = await _fcm.getToken();
            debugPrint("FCM Token: $token");
            if (token != null) {
              updateTokenOnServer(token);
            }
            break;
          }
          if (i < 5) {
            debugPrint("Waiting for APNS token in PushNotificationService (attempt ${i + 1})...");
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      } else {
        String? token = await _fcm.getToken();
        debugPrint("FCM Token: $token");
        if (token != null) {
          updateTokenOnServer(token);
        }
      }
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }

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

    try {
      String? fcmToken = token;
      if (fcmToken == null) {
        if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          if (await _fcm.getAPNSToken() == null) {
            return;
          }
        }
        fcmToken = await _fcm.getToken();
      }

      if (fcmToken != null) {
        final apiService = ApiService();

        // Get device ID
        String? deviceId;
        try {
          final deviceInfo = DeviceInfoPlugin();
          if (kIsWeb) {
            deviceId = 'web_browser';
          } else if (Platform.isAndroid) {
            final androidInfo = await deviceInfo.androidInfo;
            deviceId = androidInfo.id;
          } else if (Platform.isIOS) {
            final iosInfo = await deviceInfo.iosInfo;
            deviceId = iosInfo.identifierForVendor;
          } else if (Platform.isMacOS) {
            final macOsInfo = await deviceInfo.macOsInfo;
            deviceId = macOsInfo.systemGUID;
          }
        } catch (e) {
          debugPrint("Error getting device info: $e");
        }

        try {
          await apiService.dio.post('/fcm-token', data: {
            'fcm_token': fcmToken,
            'device_id': deviceId,
          });
          debugPrint("FCM Token updated on server");
        } catch (e) {
          debugPrint("Error updating FCM token on server: $e");
        }
      }
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'taskssphere_channel_id',
      'Tasks Notifications',
      channelDescription: 'This channel is used for task notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );

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
