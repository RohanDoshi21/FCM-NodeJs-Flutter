import 'dart:developer';

import 'package:fcm_nodejs_example/Services/local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  log('Handling a background message: ${message.messageId}');
  LocalNotificationService.createanddisplaynotification(message);
}

class FirebaseNotifications {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) => {
          if (message != null)
            {
              LocalNotificationService.createanddisplaynotification(message),
              log('Message data: ${message.notification!.title}')
            },
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) => {
          LocalNotificationService.createanddisplaynotification(message),
          log('Message data: ${message.notification!.title}'),
        });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) => {
          LocalNotificationService.createanddisplaynotification(message),
          log('Message data: ${message.notification!.title}'),
        });

    const storage = FlutterSecureStorage();

    String? fcmToken = await storage.read(key: 'fcmToken');
    if (fcmToken == null) {
      fcmToken = await _firebaseMessaging.getToken();
      await storage.write(key: 'fcmToken', value: fcmToken);

      // TODO: Send token to server
    }
    log('FCM Token: $fcmToken');
  }
}
