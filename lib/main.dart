// @dart=2.9
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tests/navbar.dart';
import 'package:flutter_tests/screens/group/components/body.dart';
import 'package:flutter_tests/screens/group/group_screen.dart';
import 'package:flutter_tests/screens/home/home_screen.dart';
import 'package:flutter_tests/splash_screen.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:page_transition/page_transition.dart';

void main() {
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
