// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print('Title: ${message.notification?.title}');
//   print('Body: ${message.notification?.body}');
//   print('Payload: ${message.data}');
// }

// class FirebaseMessagingAPI {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   void handleMessage(RemoteMessage? message) {
//     if (message == null) return;

//     //for app navigation coming from notification
//     // navigatorKey.currentState?.pushNamed(
//     //   '/',
//     // );
//   }

//   Future initPushNotifications() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     //selecting notification from app terminated state
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

//     //selecting notification from app background state
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//   }

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final fCMToken = await _firebaseMessaging.getToken();
//     print('Token: $fCMToken');

//     initPushNotifications();
//   }
// }

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class FirebaseMessagingAPI {
//   final _firebaseMessaging = FirebaseMessaging.instance;
//   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   Future<void> handleBackgroundMessage(RemoteMessage message) async {
//     print('Title: ${message.notification?.title}');
//     print('Body: ${message.notification?.body}');
//     print('Payload: ${message.data}');

//     return Future.value();
//   }

//   Future<void> handleMessage(RemoteMessage? message) async {
//     if (message == null) return;

//     // Handle the notification within the Flutter app
//     // Example: show a local notification
//     await showNotification(message.notification);
//   }

//   Future<void> initPushNotifications() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // Selecting notification from app terminated state
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

//     // Selecting notification from app background state
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//   }

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final fCMToken = await _firebaseMessaging.getToken();
//     print('Token: $fCMToken');

//     configureLocalNotifications();
//     initPushNotifications();
//   }

//   void configureLocalNotifications() {
//     print("the logo is");
//     print('drawable/notif_logo_nobg');
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('drawable/notif_logo_nobg');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//     );
//   }

//   Future<void> showNotification(RemoteNotification? notification) async {
//     print("SHOWING NOTIFICATION");
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'your_channel_id',
//       'your_channel_name',
//       channelDescription: 'your_channel_description',
//       icon: 'drawable/notif_logo_nobg', // Specify your app icon here
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.show(
//       0, // Notification ID
//       notification?.title ?? '',
//       notification?.body ?? '',
//       platformChannelSpecifics,
//     );
//   }
// }
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');

    await showNotification(message.notification);
  }

  Future<void> handleMessage(RemoteMessage message) async {
    // Handle the notification within the Flutter app
    // Example: show a local notification
    await showNotification(message.notification);
  }

  Future<void> initPushNotifications(BuildContext context) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notifications
      handleMessage(message);
    });

    // Selecting notification from app terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        handleMessage(message);
      }
    });

    // Selecting notification from app background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(message);
      Navigator.of(context).pushNamed(
          '/'); // Navigate to a specific route when app is opened from background
    });
  }

  Future<void> initNotifications(BuildContext context) async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');

    configureLocalNotifications();
    initPushNotifications(context);

    FirebaseMessaging.onBackgroundMessage(
        FirebaseMessagingBackgroundHandler.handleBackgroundMessage);
  }

  void configureLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('drawable/aquatrack_logo_nobg');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showNotification(RemoteNotification? notification) async {
    print("SHOWING NOTIFICATION");
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      icon: 'drawable/aquatrack_logo_nobg', // Specify your app icon here
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
          'notif_sound'), // Add a custom notification sound
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      notification?.title ?? '',
      notification?.body ?? '',
      platformChannelSpecifics,
    );
  }
}

class FirebaseMessagingBackgroundHandler {
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final api = FirebaseMessagingAPI();
    await api.handleBackgroundMessage(message);
  }
}
