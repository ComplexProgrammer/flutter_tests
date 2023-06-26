import 'package:flutter/material.dart';
import 'package:flutter_tests/navbar.dart';
import 'package:flutter_tests/screens/group/components/body.dart';
import 'package:flutter_tests/splash_screen.dart';

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
