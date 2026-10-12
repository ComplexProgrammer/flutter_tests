import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/services.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/features/splash_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();
  Api.init(state.prefs);
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    if (isMobile) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  unawaited(AdManager.init());
  unawaited(Reminders.apply(state.reminders));
  runApp(const SchoolTestsApp());
}

class SchoolTestsApp extends StatelessWidget {
  const SchoolTestsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'Maktab Testlari',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: state.themeMode,
        locale: state.lang.locale,
        supportedLocales: AppLang.values.map((l) => l.locale),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        ),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          final system = mq.textScaler.scale(1);
          return MediaQuery(
            data: mq.copyWith(
              textScaler:
                  TextScaler.linear((system * state.textScale).clamp(0.8, 2.0)),
            ),
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
