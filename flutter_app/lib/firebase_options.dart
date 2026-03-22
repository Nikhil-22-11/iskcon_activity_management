// File generated for Firebase project: basil-woods-activitymanagement
// To regenerate with your own keys, run:
//   flutterfire configure --project=basil-woods-activitymanagement
//
// Replace the placeholder values below with your actual Firebase credentials
// from https://console.firebase.google.com/project/basil-woods-activitymanagement/settings/general

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Replace placeholder values below with your Firebase console values ──
  // Android: download google-services.json from Firebase console and place it
  //          in flutter_app/android/app/google-services.json

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'basil-woods-activitymanagement',
    storageBucket: 'basil-woods-activitymanagement.appspot.com',
  );

  // iOS: download GoogleService-Info.plist from Firebase console and place it
  //      in flutter_app/ios/Runner/GoogleService-Info.plist

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'basil-woods-activitymanagement',
    storageBucket: 'basil-woods-activitymanagement.appspot.com',
    iosBundleId: 'com.example.iskconActivityManagement',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'basil-woods-activitymanagement',
    authDomain: 'basil-woods-activitymanagement.firebaseapp.com',
    storageBucket: 'basil-woods-activitymanagement.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'basil-woods-activitymanagement',
    storageBucket: 'basil-woods-activitymanagement.appspot.com',
    iosBundleId: 'com.example.iskconActivityManagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'basil-woods-activitymanagement',
    authDomain: 'basil-woods-activitymanagement.firebaseapp.com',
    storageBucket: 'basil-woods-activitymanagement.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );
}
