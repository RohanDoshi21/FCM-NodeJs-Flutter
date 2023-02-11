# Flutter Settings
-> Use Firebase CLI to add project
-> Change CompileSDK version to 33

```
    import 'package:firebase_core/firebase_core.dart';
    import 'package:firebase_messaging/firebase_messaging.dart';
```

Add following files
firebaes_notifcation.dart
```
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
```

local_notification.dart
```
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
// initializationSettings for Android
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    _notificationsPlugin.initialize(initializationSettings);
  }

  static void createanddisplaynotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "pushnotificationapp",
          "pushnotificationappchannel",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
```

To your main.dart
```
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseNotifications.initialize();
  runApp(const MyApp());
}
```

