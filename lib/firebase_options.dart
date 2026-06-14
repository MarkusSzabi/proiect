import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7uDvVW8Pv0u_QAtJShDDoYXEGOEAZwLM',
    appId: '1:668396135194:android:4b2e51875cc12626c382a3',
    messagingSenderId: '668396135194',
    projectId: 'smart-driver-assitant',
    storageBucket: 'smart-driver-assitant.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7uDvVW8Pv0u_QAtJShDDoYXEGOEAZwLM',
    appId: '1:668396135194:android:4b2e51875cc12626c382a3',
    messagingSenderId: '668396135194',
    projectId: 'smart-driver-assitant',
    storageBucket: 'smart-driver-assitant.firebasestorage.app',
    iosBundleId: 'com.company.smartdriverassistant',
  );
}