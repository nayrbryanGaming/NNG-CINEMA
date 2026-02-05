// Firebase Configuration - API keys loaded from environment variables for security
// IMPORTANT: Run with dart-define flags or configure in your CI/CD pipeline
// flutter run --dart-define=FIREBASE_API_KEY=xxx --dart-define=FIREBASE_APP_ID=xxx ...

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  // Environment variables for Firebase configuration
  static const String _apiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String _appId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const String _messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  static const String _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  static const String _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');

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

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: 'com.nng_cinema',
  );
}
