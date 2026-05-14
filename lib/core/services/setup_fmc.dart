// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../cache_helper/cache_helper.dart';
// import '../cache_helper/cache_values.dart';

// final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// final FirebaseMessaging messaging = FirebaseMessaging.instance;

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   await showNotification(message);
// }

// Future<void> getFCMToken() async {
//   try {
//     final token = await messaging.getToken();
//     final fcmToken = token;
//     await CacheHelper.setSecured(
//       key: CacheKeys.deviceToken,
//       value: fcmToken,
//     );
//   } catch (e) {
//     debugPrint('Error getting FCM token: $e');
//   }
// }

// Future<void> setupFCM() async {
//   try {
//     const androidSettings = AndroidInitializationSettings('notification_icon');
//     const initializationSettingsIOS = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: initializationSettingsIOS,
//     );
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//     await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     await flutterLocalNotificationsPlugin.initialize(initSettings);
//     await FirebaseMessaging.instance.setAutoInitEnabled(true);

//     FirebaseMessaging.onMessage.listen(showNotification);

//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       debugPrint('Notification clicked: ${message.data}');
//     });
//   } on PlatformException catch (e) {
//     debugPrint('Error loading ic_launcher: ${e.message}');
//   }
// }

// Future<void> showNotification(RemoteMessage message) async {
//   const androidDetails = AndroidNotificationDetails(
//     'channel_id',
//     'General Notifications',
//     importance: Importance.max,
//     priority: Priority.high,
//   );

//   const iosDetails = DarwinNotificationDetails(
//     presentAlert: true,
//     presentBadge: true,
//     presentSound: true,
//   );
//   const notificationDetails = NotificationDetails(
//     android: androidDetails,
//     iOS: iosDetails,
//   );
//   await flutterLocalNotificationsPlugin.show(
//     0,
//     message.notification?.title ?? '',
//     message.notification?.body ?? '',
//     notificationDetails,
//   );
// }
