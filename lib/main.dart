// lib/main.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'push/push_service.dart';

import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/firebase/auth_service.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:gotocarefinder/utils/localstring.dart';
import 'helpar/get_di.dart' as di;

import 'package:flutter_stripe/flutter_stripe.dart';

// Only import; we gate calls per-platform.
import 'package:permission_handler/permission_handler.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Platform helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
bool get _isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
bool get _isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
bool get _isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ OneSignal (mobile only) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Future<void> _initOneSignalIfMobile() async {
  if (_isAndroid || _isIOS) {
    try {
      // TODO: initialize OneSignal here if you use it on mobile.
      // OneSignal.initialize('YOUR_ONESIGNAL_APP_ID');
      // await OneSignal.Notifications.requestPermission(true);
      debugPrint('OneSignal initialized (mobile).');
    } catch (e, st) {
      debugPrint('OneSignal init failed: $e');
      debugPrintStack(stackTrace: st);
    }
  } else {
    debugPrint('OneSignal skipped on this platform.');
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ main() â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log uncaught Flutter errors to console (handy during web debugging).
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrintStack(label: 'Uncaught Flutter Error', stackTrace: details.stack);
  };

  // 0) Stripe must be configured BEFORE any usage.
  // Use --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx for builds,
  // OR keep a non-empty defaultValue for local dev.
  Stripe.publishableKey = const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51QEi1IKsgilDLeQ66c21MI1bfcP59jzVRFD3sDlK8V7psiT0wg8p0qvL2PHtTezj3DVtK19zcQlk3nWM5fKbS3T100VdHIpFEI',
  );
  // iOS Apple Pay merchant id (safe to set even if you don't use AP yet)
  Stripe.merchantIdentifier = 'merchant.com.gotocarefinder';
  await Stripe.instance.applySettings();

  // 1) Push service (no-op on web as per your PushService implementation)
  await PushService.instance.init();
  await PushService.instance.requestPermission();

  // 2) Notifications / Permissions per-platform
  if (kIsWeb) {
    // Web: Skip notification permissions (Firebase removed)
    debugPrint('Web notifications skipped (Firebase removed).');
  } else if (_isLinux) {
    debugPrint('Skipping notifications/permissions on Linux.');
  } else {
    // Android / iOS / macOS / Windows
    try {
      await Permission.notification.request();
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  // 3) Load environment variables from .env
  await Config.loadEnv();

  // 4) Initialize OneSignal ONLY on mobile platforms
  await _initOneSignalIfMobile();

  // 5) Storage & DI
  await GetStorage.init();
  await di.init();

  // 5) Run app
  runApp(const MyApp());
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ MyApp â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorNotifire()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          dividerColor: Colors.transparent,
          primaryColor: const Color(0xff3D5BF6),
          useMaterial3: false,
          fontFamily: 'Gilroy',
        ),
        initialRoute: Routes.initial,
        translations: LocaleString(),
        locale: const Locale('en_US', 'en_US'),
        getPages: getPages,
      ),
    );
  }
}

