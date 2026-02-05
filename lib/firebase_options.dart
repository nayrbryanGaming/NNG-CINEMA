// Firebase Configuration for NNG-CINEMA
// Uses environment variables with fallback to hardcoded values
// Run with: flutter run --dart-define=FIREBASE_API_KEY=xxx (optional)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  // Environment variables with fallback defaults
  static const String _envApiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String _envAppId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const String _envMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  static const String _envProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  static const String _envStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');

  // Fallback values
  static const String _defaultApiKey = 'AIzaSyB9VqRd_vU6q1g1t1CoHQJU-2XEX5PxHhU';
  static const String _defaultAppId = '1:994610973675:android:5a0d90a249cc100793e7ae';
  static const String _defaultMessagingSenderId = '994610973675';
  static const String _defaultProjectId = 'nng-cinema';
  static const String _defaultStorageBucket = 'nng-cinema.firebasestorage.app';

  static String get _apiKey => _envApiKey.isEmpty ? _defaultApiKey : _envApiKey;
  static String get _appId => _envAppId.isEmpty ? _defaultAppId : _envAppId;
  static String get _messagingSenderId => _envMessagingSenderId.isEmpty ? _defaultMessagingSenderId : _envMessagingSenderId;
  static String get _projectId => _envProjectId.isEmpty ? _defaultProjectId : _envProjectId;
  static String get _storageBucket => _envStorageBucket.isEmpty ? _defaultStorageBucket : _envStorageBucket;

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
