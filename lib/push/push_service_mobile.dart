import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'push_service.dart';

// If you use OneSignal, import it here:
// import 'package:onesignal_flutter/onesignal_flutter.dart';

PushService getPushService() => _MobilePushService();

class _MobilePushService implements PushService {
  @override
  Future<void> init() async {
    log('PushService(mobile): init');

    // Example OneSignal init (uncomment and fill your app id)
    // OneSignal.initialize('YOUR_ONESIGNAL_APP_ID');
    // await OneSignal.Notifications.requestPermission(true);

    // Or if you prefer FCM on mobile, initialize it here instead.
  }

  @override
  Future<void> requestPermission() async {
    try {
      await Permission.notification.request();
    } catch (_) {
      // ignore
    }
  }

  @override
  Future<String?> getPushToken() async {
    // Example with OneSignal:
    // final token = await OneSignal.User.pushSubscription.token;
    // return token;

    return null;
  }
}
