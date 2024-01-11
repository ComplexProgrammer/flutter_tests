import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tests/navbar.dart';
import 'package:flutter_tests/screens/group/components/body.dart';
import 'package:flutter_tests/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  unawaited(MobileAds.instance.initialize());
  runApp(SplashApp());
}

class MyApp extends StatelessWidget {
  // const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: const Text('Tests for School'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Body(),
      ),
      // home: GroupScreen(),
    );
  }
}
