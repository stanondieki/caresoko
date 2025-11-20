import 'push_service.dart';

PushService getPushService() => _StubPushService();

class _StubPushService implements PushService {
  @override
  Future<void> init() async {}
  @override
  Future<void> requestPermission() async {}
  @override
  Future<String?> getPushToken() async => null;
}
