import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/routes/app_router.dart';
import 'core/l10n/app_localizations.dart';
// import 'modules/arrow_sense/lib/l10n/arrow_sense_localizations.dart';
import 'core/constants/app_info.dart';
import 'core/services/prefs_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/network/cookie/cookie_manager.dart';

// Modular Architecture
import 'modules/all_modules.dart';
import 'modules/module_registry.dart';

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

  // Firebase & Remote Config
  // Aktifkan dengan REMOTE_CONFIG_ENABLE=true di .env
  // Firebase.initializeApp() dipanggil otomatis saat REMOTE_CONFIG_ENABLE=true

  // ============================================
  // REGISTER MODULES
  // ============================================
  // Modules will only be active if enabled in .env
  ModuleManifest.register();

  // Print module status for debugging
  ModuleRegistry.printDebugInfo();

  // Initialize cookie manager if enabled (must be before other async initializations)
  if (AppInfo.authUseCookie) {
    await CookieManager.instance.initialize(usePersistentCookies: true);
    debugPrint('[Main] Cookie management enabled');
  }

  // Initialize services in PARALLEL for better performance
  // This reduces startup time by running async operations concurrently
  await Future.wait([
    // Initialize SharedPreferences early (cached for entire app lifecycle)
    PrefsService.initialize(),
    // Initialize version info from pubspec.yaml
    AppInfo.initialize(),
    // Initialize all active modules
    ModuleRegistry.initializeAll(),
    // Firebase & Remote Config (diaktifkan via REMOTE_CONFIG_ENABLE=true di .env)
    if (AppInfo.remoteConfigEnable)
      Firebase.initializeApp().then((_) => RemoteConfigService.initialize()).catchError((e) {
        debugPrint('[Main] Firebase initialization error (non-fatal): $e');
      }),
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
        Locale('tr', 'TR'),
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        // ArrowSenseLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router
      routerConfig: router,
    );
  }
}
