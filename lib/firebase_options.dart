// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'dart:io' show Platform;

class PlatformUtils {
  static bool get isMobile {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isIOS || Platform.isAndroid;
    }
  }

  static bool get isDesktop {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isLinux ||
          Platform.isFuchsia ||
          Platform.isWindows ||
          Platform.isMacOS;
    }
  }
}

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDpWaFi5QLTNc-yY0ieMKJtGOmbm2ofBm4',
    appId: '1:755681568857:web:102b1b733df55baefe2948',
    messagingSenderId: '755681568857',
    projectId: 'c0mplex',
    authDomain: 'c0mplex.firebaseapp.com',
    storageBucket: 'c0mplex.appspot.com',
    measurementId: 'G-H8XGTS4B9J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBj21ySm8AfeCowiUXpopDt9W7KEDdAjPg',
    appId: '1:755681568857:android:ed654b9ffe2b00befe2948',
    messagingSenderId: '755681568857',
    projectId: 'c0mplex',
    storageBucket: 'c0mplex.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3TOK1bDImOOBg15A5yQht9C25_e9B3LQ',
    appId: '1:755681568857:ios:397924731922ed0cfe2948',
    messagingSenderId: '755681568857',
    projectId: 'c0mplex',
    storageBucket: 'c0mplex.appspot.com',
    androidClientId:
        '755681568857-jiba8btc2cangp6luj6e5kuf0u035eiu.apps.googleusercontent.com',
    iosClientId:
        '755681568857-980djgobqq1ac166u1c8to6gjjkrpq9n.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterTests',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA3TOK1bDImOOBg15A5yQht9C25_e9B3LQ',
    appId: '1:755681568857:ios:397924731922ed0cfe2948',
    messagingSenderId: '755681568857',
    projectId: 'c0mplex',
    storageBucket: 'c0mplex.appspot.com',
    androidClientId:
        '755681568857-jiba8btc2cangp6luj6e5kuf0u035eiu.apps.googleusercontent.com',
    iosClientId:
        '755681568857-980djgobqq1ac166u1c8to6gjjkrpq9n.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterTests',
  );
}