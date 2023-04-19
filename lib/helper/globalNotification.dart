import 'package:chatme/service/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

final _messaging = FirebaseMessaging.instance;
final globalFCMToken = _messaging.getToken();

class GlobalNotificationSetup {
  Future registerNotification() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _messaging.setAutoInitEnabled(true);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');
      });
    } else {
      print('User declined or has not accepted permission');
    }
    await NotificationService.initializeNotification();
    //  NotificationService().foregroundNotify;
  }
}
