import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:firebase_core/firebase_core.dart';  // Disabled to reduce APK size
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/routes/app_router.dart';
import 'core/l10n/app_localizations.dart';
import 'core/constants/app_info.dart';
import 'core/services/prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (must be first)
  await dotenv.load(fileName: ".env");

  // Run non-blocking UI configurations synchronously
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Firebase disabled to reduce APK size
  // Uncomment below to re-enable Firebase
  // final shouldInitFirebase = AppInfo.enableNotification &&
  //     (AppInfo.notificationProvider.toLowerCase() == 'firebase' ||
  //      AppInfo.notificationProvider.toLowerCase() == 'fcm');

  // Initialize services in PARALLEL for better performance
  // This reduces startup time by running async operations concurrently
  await Future.wait([
    // Initialize SharedPreferences early (cached for entire app lifecycle)
    PrefsService.initialize(),
    // Firebase initialization disabled
    // if (shouldInitFirebase)
    //   Firebase.initializeApp().catchError((e) {
    //     debugPrint('Firebase initialization error: $e');
    //     return Firebase.app(); // Return existing app or handle gracefully
    //   }),
  ]);

  runApp(
    const ProviderScope(
      child: SuperApp(),
    ),
  );
}


class SuperApp extends ConsumerWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Super App',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: theme,

      // Locale
      locale: locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router
      routerConfig: router,
    );
  }
}
