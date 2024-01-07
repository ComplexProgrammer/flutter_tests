import 'package:flutter/material.dart';
import 'package:flutter_tests/main.dart';
import 'package:flutter_tests/screens/group/group_screen.dart';
// ignore: import_of_legacy_library_into_null_safe
// import 'package:splashscreen/splashscreen.dart';

class SplashApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tests for School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyApp(),
      // home: SplashScreen(
      //   seconds: 3,
      //   navigateAfterSeconds: MyApp(),
      //   title: const Text(
      //     'www.complexprogrammer.uz',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 20.0,
      //       color: Colors.white,
      //     ),
      //   ),
      //   image: Image.network(
      //     '$baseUrl/static/img/icon_512.png',
      //   ),
      //   backgroundColor: Colors.lightBlue,
      // ),
    );
  }
}
