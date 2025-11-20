// Picks the right implementation at compile-time:
// - Mobile/Desktop (dart:io) -> OneSignal implementation
// - Web (dart:html)          -> No-op safe implementation
import 'push_service_stub.dart'
if (dart.library.io) 'push_service_mobile.dart'
if (dart.library.html) 'push_service_web.dart';

abstract class PushService {
  static final instance = getPushService();

  Future<void> init();               // initialize SDK / permissions
  Future<void> requestPermission();  // ask user (no-op on web for OneSignal)
  Future<String?> getPushToken();    // token if available, else null
}
