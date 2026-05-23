import 'dart:developer';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'push_service.dart';

PushService getPushService() => _MobilePushService();

class _MobilePushService implements PushService {
  @override
  Future<void> init() async {
    log('PushService(mobile): init');

    final appId = Config.oneSignel;
    if (appId != "****" && appId.isNotEmpty) {
      OneSignal.initialize(appId);
      await OneSignal.Notifications.requestPermission(true);
    } else {
      log('PushService(mobile): OneSignal appId not configured, skipping.');
    }
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
