import 'dart:developer';
import 'push_service.dart';

PushService getPushService() => _WebPushService();

class _WebPushService implements PushService {
  @override
  Future<void> init() async {
    // No OneSignal calls here (avoids MissingPluginException).
    // If you later use FCM Web, wire it here instead.
    log('PushService(web): init (no-op)');
  }

  @override
  Future<void> requestPermission() async {
    // If you migrate to FCM Web, request Notification permission here.
    log('PushService(web): requestPermission (no-op)');
  }

  @override
  Future<String?> getPushToken() async => null;
}
