// Firebase Configuration for NNG-CINEMA

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9VqRd_vU6q1g1t1CoHQJU-2XEX5PxHhU',
    appId: '1:994610973675:android:5a0d90a249cc100793e7ae',
    messagingSenderId: '994610973675',
    projectId: 'nng-cinema',
    storageBucket: 'nng-cinema.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB9VqRd_vU6q1g1t1CoHQJU-2XEX5PxHhU',
    appId: '1:994610973675:android:5a0d90a249cc100793e7ae',
    messagingSenderId: '994610973675',
    projectId: 'nng-cinema',
    storageBucket: 'nng-cinema.firebasestorage.app',
    iosBundleId: 'com.nng_cinema',
  );
}
