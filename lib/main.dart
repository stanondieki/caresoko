// lib/main.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'push/push_service.dart';

import 'package:gotocarefinder/firebase/auth_service.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:gotocarefinder/utils/localstring.dart';
import 'helpar/get_di.dart' as di;

import 'package:flutter_stripe/flutter_stripe.dart';

// Only import; we gate calls per-platform.
import 'package:permission_handler/permission_handler.dart';

// ───────────────────────── Platform helpers ─────────────────────────
bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
bool get _isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
bool get _isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
bool get _isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

// ───────────────────────── OneSignal (mobile only) ────────────────────
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

// ─────────────────────────────── main() ───────────────────────────────
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

  // 3) Initialize OneSignal ONLY on mobile platforms
  await _initOneSignalIfMobile();

  // 4) Storage & DI
  await GetStorage.init();
  await di.init();

  // 5) Run app
  runApp(const MyApp());
}

// ───────────────────────────── MyApp ─────────────────────────────────
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






























// import 'package:flutter/foundation.dart'
//     show kIsWeb, defaultTargetPlatform, TargetPlatform;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:provider/provider.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// import 'package:gotocarefinder/firebase/auth_service.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:gotocarefinder/utils/localstring.dart';
// import 'helpar/get_di.dart' as di;
//
// // Only used on mobile/desktop platforms that support it (not web)
// import 'package:permission_handler/permission_handler.dart';
//
// // ─────────────────────────────────────────────────────────────
// // 🔧 Web FirebaseOptions (FILL THESE VALUES)
// // Get these from Firebase Console → Project settings → Web app → "SDK setup and configuration"
// const FirebaseOptions firebaseWebOptions = FirebaseOptions(
//   apiKey: 'YOUR_WEB_API_KEY',
//   authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
//   projectId: 'YOUR_PROJECT_ID',
//   storageBucket: 'YOUR_PROJECT_ID.appspot.com',
//   messagingSenderId: 'YOUR_SENDER_ID',
//   appId: 'YOUR_WEB_APP_ID',
//   measurementId: 'G-XXXXXXXXXX', // optional but recommended
// );
//
// // ───────── Optional stubs if these live elsewhere ─────────
// Future<void> initializeNotifications() async {}
// void loadFCM() {}
// void listenFCM() {}
// Future<void> getLocation() async {}
// Future<void> requestPermission() async {}
//
// // Background FCM handler (Android/iOS only)
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('BG message: ${message.messageId}');
// }
//
// bool get _isLinux =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
// bool get _isAndroid =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
// bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
// bool get _isMacOS =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
// bool get _isWindows =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
//
// /// We’ll use Firebase on: Web, Android, iOS, macOS, Windows
// bool get _supportsFirebase =>
//     kIsWeb || _isAndroid || _isIOS || _isMacOS || _isWindows;
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.dumpErrorToConsole(details);
//     debugPrintStack(label: "Uncaught Flutter Error", stackTrace: details.stack);
//   };
//
//   // 1) Firebase init ONLY where supported
//   if (_supportsFirebase) {
//     if (kIsWeb) {
//       // Web requires explicit FirebaseOptions
//       await Firebase.initializeApp(options: firebaseWebOptions);
//     } else {
//       // Mobile/desktop builds that use google-services/Info.plist can use default init
//       await Firebase.initializeApp();
//     }
//   } else {
//     // Linux: skip Firebase to avoid "channel-error" / missing implementations
//     debugPrint('Firebase skipped on Linux desktop.');
//   }
//
//   // 2) Permissions / Notifications / FCM
//   if (kIsWeb) {
//     // Web: Ask browser notification permission through FCM
//     await FirebaseMessaging.instance.requestPermission();
//     // Do NOT use flutter_local_notifications or permission_handler on web
//   } else if (_isLinux) {
//     // Linux: Skip permission_handler and FCM background/local notifications
//   } else {
//     // Android / iOS / macOS / Windows
//     if (_isAndroid) {
//       // Only Android has "storage"/"phone" permissions
//       await Permission.storage.request();
//       await Permission.phone.request();
//     } else if (_isIOS || _isMacOS || _isWindows) {
//       // Optional: request notifications permission
//       await Permission.notification.request();
//     }
//
//     await getLocation();
//
//     if (_isAndroid || _isIOS) {
//       FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//       await initializeNotifications();
//       loadFCM();
//       listenFCM();
//       requestPermission();
//     }
//   }
//
//   // 3) Storage & DI
//   await GetStorage.init();
//   await di.init();
//
//   // 4) Run app
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ColorNotifire()),
//         ChangeNotifierProvider(create: (_) => AuthService()),
//       ],
//       child: GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           splashColor: Colors.transparent,
//           hoverColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           dividerColor: Colors.transparent,
//           primaryColor: const Color(0xff3D5BF6),
//           useMaterial3: false,
//           fontFamily: "Gilroy",
//         ),
//         initialRoute: Routes.initial,
//         translations: LocaleString(),
//         locale: const Locale('en_US', 'en_US'),
//         getPages: getPages,
//       ),
//     );
//   }
// }


// import 'package:flutter/foundation.dart'
//     show kIsWeb, defaultTargetPlatform, TargetPlatform;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:provider/provider.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// import 'package:gotocarefinder/firebase/auth_service.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:gotocarefinder/utils/localstring.dart';
// import 'helpar/get_di.dart' as di;
// import 'firebase_options.dart';
//
//
// // Only used on supported platforms (NOT web, NOT linux)
// import 'package:permission_handler/permission_handler.dart';
//
// // ───────── Optional stubs if these live elsewhere ─────────
// Future<void> initializeNotifications() async {}
// void loadFCM() {}
// void listenFCM() {}
// Future<void> getLocation() async {}
// Future<void> requestPermission() async {}
//
// // Background FCM handler (Android/iOS only)
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('BG message: ${message.messageId}');
// }
//
// bool get _isLinux =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
// bool get _isAndroid =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
// bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
// bool get _isMacOS =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
// bool get _isWindows =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
//
// /// Firebase is supported on: Android, iOS, Web, macOS, Windows
// bool get _supportsFirebase =>
//     kIsWeb || _isAndroid || _isIOS || _isMacOS || _isWindows;
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.dumpErrorToConsole(details);
//     debugPrintStack(label: "Uncaught Flutter Error", stackTrace: details.stack);
//   };
//
//   // 1) Firebase init ONLY where supported
//   // if (_supportsFirebase) {
//   //   await Firebase.initializeApp();
//   // } else {
//   //   // Linux: skip Firebase completely to avoid channel errors
//   //   debugPrint('Firebase skipped on Linux desktop.');
//   // }
//   // 1) Firebase init ONLY where supported
//   if (_supportsFirebase) {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform, // <-- required on Web
//     );
//   } else {
//     // Linux: skip Firebase completely to avoid channel errors
//     debugPrint('Firebase skipped on Linux desktop.');
//   }
//
//
//   // 2) Permissions / Notifications / FCM
//   if (kIsWeb) {
//     // Web: use FCM’s browser permission prompt
//     await FirebaseMessaging.instance.requestPermission();
//   } else if (_isLinux) {
//     // Linux: skip permission_handler, FCM bg handlers, and local notifications
//   } else {
//     // Android / iOS / macOS / Windows
//     if (_isAndroid) {
//       await Permission.storage.request();
//       await Permission.phone.request();
//     } else if (_isIOS || _isMacOS || _isWindows) {
//       // Optional: request notifications permission
//       await Permission.notification.request();
//     }
//
//     await getLocation();
//
//     if (_isAndroid || _isIOS) {
//       FirebaseMessaging.onBackgroundMessage(
//           _firebaseMessagingBackgroundHandler);
//       await initializeNotifications();
//       loadFCM();
//       listenFCM();
//       requestPermission();
//     }
//   }
//
//   // 3) Storage & DI
//   await GetStorage.init();
//   await di.init();
//
//   // 4) Run app
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ColorNotifire()),
//         ChangeNotifierProvider(create: (_) => AuthService()),
//       ],
//       child: GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           splashColor: Colors.transparent,
//           hoverColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           dividerColor: Colors.transparent,
//           primaryColor: const Color(0xff3D5BF6),
//           useMaterial3: false,
//           fontFamily: "Gilroy",
//         ),
//         initialRoute: Routes.initial,
//         translations: LocaleString(),
//         locale: const Locale('en_US', 'en_US'),
//         getPages: getPages,
//       ),
//     );
//   }
// }
// lib/main.dart

// import 'package:flutter/foundation.dart'
//     show kIsWeb, defaultTargetPlatform, TargetPlatform;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:provider/provider.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// import 'firebase_options.dart'; // <-- generated by flutterfire configure
// import 'push/push_service.dart';
//
//
// import 'package:gotocarefinder/firebase/auth_service.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:gotocarefinder/utils/localstring.dart';
// import 'helpar/get_di.dart' as di;
// import 'package:flutter_stripe/flutter_stripe.dart';
//
//
// // Only import; we'll guard usage so it's never called on web/Linux.
// import 'package:permission_handler/permission_handler.dart';
//
// // ───────────────────────── Platform helpers ─────────────────────────
//
// bool get _isAndroid =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
// bool get _isIOS =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
// bool get _isMacOS =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
// bool get _isWindows =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
// bool get _isLinux =>
//     !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
//
// /// Firebase is supported on: Android, iOS, Web, macOS, Windows.
// /// (Linux support for many Firebase plugins is limited; skip to avoid runtime issues.)
// bool get _supportsFirebase =>
//     kIsWeb || _isAndroid || _isIOS || _isMacOS || _isWindows;
//
// // ─────────────────────── Background FCM (mobile) ─────────────────────
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Android/iOS only; web won't call this.
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   debugPrint('BG message: ${message.messageId}');
// }
//
// // ───────────────────────── OneSignal (mobile only) ────────────────────
//
// // NOTE: Your previous crash was OneSignal on web.
// // Keep all OneSignal calls *inside* this guarded function and call it after Firebase init.
// // If you use a OneSignal service, invoke it here for Android/iOS only.
// Future<void> _initOneSignalIfMobile() async {
//   if (_isAndroid || _isIOS) {
//     try {
//       // TODO: Uncomment and add your OneSignal init if you use it on mobile:
//       // OneSignal.initialize('YOUR_ONESIGNAL_APP_ID');
//       // await OneSignal.Notifications.requestPermission(true);
//       debugPrint('OneSignal initialized (mobile).');
//     } catch (e, st) {
//       debugPrint('OneSignal init failed: $e');
//       debugPrintStack(stackTrace: st);
//     }
//   } else {
//     debugPrint('OneSignal skipped on this platform.');
//   }
// }
//
// // ─────────────────────────────── main() ───────────────────────────────
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Log uncaught Flutter errors to console (handy during web debugging).
//   FlutterError.onError = (details) {
//     FlutterError.dumpErrorToConsole(details);
//     debugPrintStack(
//       label: 'Uncaught Flutter Error',
//       stackTrace: details.stack,
//     );
//   };
//
//   // 1) Firebase init (with options on web)
//   if (_supportsFirebase) {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } else {
//     debugPrint('Firebase skipped on Linux desktop.');
//   }
//
//   // ⚠️ Set at runtime (DON'T hardcode in source; use env or remote config)
//   Stripe.publishableKey = const String.fromEnvironment('pk_test_51QEi1IKsgilDLeQ66c21MI1bfcP59jzVRFD3sDlK8V7psiT0wg8p0qvL2PHtTezj3DVtK19zcQlk3nWM5fKbS3T100VdHIpFEI',
//       defaultValue: 'pk_test_51QEi1IKsgilDLeQ66c21MI1bfcP59jzVRFD3sDlK8V7psiT0wg8p0qvL2PHtTezj3DVtK19zcQlk3nWM5fKbS3T100VdHIpFEI'); // dev key
//   Stripe.merchantIdentifier = 'merchant.com.gotocarefinder'; // iOS Apple Pay id (can be any string until you enable AP)
//   await Stripe.instance.applySettings();
//   await PushService.instance.init();
//   await PushService.instance.requestPermission();
//
//   // 2) Notifications / Permissions per-platform
//   if (kIsWeb) {
//     // Web: Ask the browser for notification permission via FCM
//     try {
//       await FirebaseMessaging.instance.requestPermission();
//     } catch (e) {
//       debugPrint('Web notifications permission request failed: $e');
//     }
//   } else if (_isLinux) {
//     // Linux desktop: skip permission_handler and local notifications
//     debugPrint('Skipping notifications/permissions on Linux.');
//   } else {
//     // Android / iOS / macOS / Windows
//     try {
//       if (_isAndroid) {
//         // Request only what you actually need
//         await Permission.notification.request();
//         // If you truly need these, keep them; otherwise remove:
//         // await Permission.storage.request();
//         // await Permission.phone.request();
//       } else if (_isIOS || _isMacOS || _isWindows) {
//         await Permission.notification.request();
//       }
//     } catch (e) {
//       debugPrint('Permission request error: $e');
//     }
//
//     // FCM background handler (Android/iOS)
//     if (_isAndroid || _isIOS) {
//       FirebaseMessaging.onBackgroundMessage(
//         _firebaseMessagingBackgroundHandler,
//       );
//     }
//   }
//
//   // 3) Initialize OneSignal ONLY on mobile platforms
//   await _initOneSignalIfMobile();
//
//   // 4) Storage & DI
//   await GetStorage.init();
//   await di.init();
//
//   // 5) Run app
//   runApp(const MyApp());
// }
//
// // ───────────────────────────── MyApp ─────────────────────────────────
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ColorNotifire()),
//         ChangeNotifierProvider(create: (_) => AuthService()),
//       ],
//       child: GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           splashColor: Colors.transparent,
//           hoverColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           dividerColor: Colors.transparent,
//           primaryColor: const Color(0xff3D5BF6),
//           useMaterial3: false,
//           fontFamily: 'Gilroy',
//         ),
//         initialRoute: Routes.initial,
//         translations: LocaleString(),
//         locale: const Locale('en_US', 'en_US'),
//         getPages: getPages,
//       ),
//     );
//   }
// }
//
//

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:gotocarefinder/firebase/auth_service.dart';
// import 'package:gotocarefinder/firebase/chat_screen.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/screen/splesh_screen.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:gotocarefinder/utils/localstring.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'helpar/get_di.dart' as di;
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.dumpErrorToConsole(details);
//     debugPrintStack(label: "Uncaught Flutter Error", stackTrace: details.stack);
//   };
//
//   //await Firebase.initializeApp();
//   await Permission.storage.request();
//   await Permission.phone.request();
//   await getLocation();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   requestPermission();
//   listenFCM();
//   loadFCM();
//   initializeNotifications();
//
//   await GetStorage.init();
//   await di.init();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ColorNotifire()),
//         ChangeNotifierProvider(create: (_) => AuthService()),
//       ],
//       child: GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//             splashColor: Colors.transparent,
//             hoverColor: Colors.transparent,
//             highlightColor: Colors.transparent,
//             dividerColor: Colors.transparent,
//             primaryColor: const Color(0xff3D5BF6),
//             useMaterial3: false,
//             fontFamily: "Gilroy"),
//         initialRoute: Routes.initial,
//         translations: LocaleString(),
//         locale: const Locale('en_US', 'en_US'),
//         getPages: getPages,
//       ),
//     );
//   }
// }
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
