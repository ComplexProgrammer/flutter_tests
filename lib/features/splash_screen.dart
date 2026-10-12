import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/features/home_screen.dart';
import 'package:flutter_tests/features/onboarding_screen.dart';

/// Short branded splash that warms up the subject list in the background.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final preload = Api.groups().then((_) {}, onError: (_) {});
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 900)),
      preload.timeout(const Duration(seconds: 3), onTimeout: () {}),
    ]);
    if (!mounted) return;
    final next = AppState.instance.onboardingSeen
        ? const HomeScreen()
        : const OnboardingScreen();
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => next,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kVibrantGradient),
        child: Center(
          child: FadeTransition(
            opacity: _c,
            child: ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.0).animate(curve),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35), width: 2),
                    ),
                    child: const Icon(Icons.quiz_rounded,
                        size: 72, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(context.tr('app_name'),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(context.tr('app_tagline'),
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
