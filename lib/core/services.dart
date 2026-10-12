import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:url_launcher/url_launcher.dart';

bool get isMobile =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

const kTelegramUrl = 'https://t.me/schooltestsuzb';
const kFeedbackEmail = 'complexprogrammer@mail.ru';
const kPrivacyUrl = 'https://complexprogrammer.uz/privacy/';
const kAndroidPackage = 'schooltests.complexprogrammer.uz';
const kStoreUrl =
    'https://play.google.com/store/apps/details?id=$kAndroidPackage';

/// Sound effects and haptics, respecting the user's settings.
class Sfx {
  static final _players = <String, AudioPlayer>{};

  static Future<void> _play(String name) async {
    if (!AppState.instance.sound) return;
    try {
      final player = _players.putIfAbsent(
          name, () => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      await player.stop();
      await player.play(AssetSource('raw/$name.mp3'));
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  static void tap() {
    if (AppState.instance.haptics) HapticFeedback.selectionClick();
  }

  static void right() {
    _play('right');
    if (AppState.instance.haptics) HapticFeedback.lightImpact();
  }

  static void wrong() {
    _play('wrong');
    if (AppState.instance.haptics) HapticFeedback.heavyImpact();
  }

  static void click() => _play('click');
}

/// Interstitials are shown only after a finished test, at most every second
/// time and not more often than every 3 minutes.
class AdManager {
  static const _interstitialId = 'ca-app-pub-7773722896374259/2232999799';
  static InterstitialAd? _ad;
  static DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);
  static int _finished = 0;
  static bool _loading = false;

  static Future<void> init() async {
    if (!isMobile) return;
    await MobileAds.instance.initialize();
    preload();
  }

  static void preload() {
    if (!isMobile || _ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (e) {
          _loading = false;
          debugPrint('Interstitial failed: $e');
        },
      ),
    );
  }

  static void onQuizFinished() {
    if (!isMobile) return;
    _finished++;
    final ad = _ad;
    if (ad == null) return preload();
    if (_finished % 2 != 0 ||
        DateTime.now().difference(_lastShown) < const Duration(minutes: 3)) {
      return;
    }
    _ad = null;
    _lastShown = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        preload();
      },
    );
    ad.show();
  }
}

/// Daily reminders are delivered through the FCM topic `daily_reminder`
/// (scheduled from the Firebase console / backend).
class Reminders {
  static const topic = 'daily_reminder';

  static Future<void> apply(bool enabled) async {
    if (!isMobile) return;
    try {
      final fm = FirebaseMessaging.instance;
      if (enabled) {
        await fm.requestPermission();
        await fm.subscribeToTopic(topic);
      } else {
        await fm.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      debugPrint('Reminders error: $e');
    }
  }
}

Future<void> openLink(BuildContext context, String url) async {
  final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)
      .catchError((_) => false);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.tr('err_open_link'))));
  }
}

Future<void> sendEmail(BuildContext context, String subject, String body) =>
    openLink(
        context,
        Uri(
          scheme: 'mailto',
          path: kFeedbackEmail,
          query:
              'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
        ).toString());
