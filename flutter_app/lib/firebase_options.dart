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
    apiKey: 'AIzaSyDND_0GL-MXTEng9IJwV_SGcgAwsPb2hWc',
    appId: '1:487039653770:android:fef7488a86526dcd209a73',
    messagingSenderId: '487039653770',
    projectId: 'basil-woods-activitymanagement',
    storageBucket: 'basil-woods-activitymanagement.firebasestorage.app',
  );

  // iOS: download GoogleService-Info.plist from Firebase console and place it
  //      in flutter_app/ios/Runner/GoogleService-Info.plist

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCmmlcxg2CTUHYj0TSUa68M_bw_W0ehp3A',
    appId: '1:487039653770:ios:4332c1e4a182147c209a73',
    messagingSenderId: '487039653770',
    projectId: 'basil-woods-activitymanagement',
    storageBucket: 'basil-woods-activitymanagement.firebasestorage.app',
    iosBundleId: 'com.example.iskconActivityManagement',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBP-RdyDlk5kVhbgpPqkPx-TWPbVS5nDZE',
    appId: '1:487039653770:web:1c59ad22f645b972209a73',
    messagingSenderId: '487039653770',
    projectId: 'basil-woods-activitymanagement',
    authDomain: 'basil-woods-activitymanagement.firebaseapp.com',
    storageBucket: 'basil-woods-activitymanagement.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCmmlcxg2CTUHYj0TSUa68M_bw_W0ehp3A',
    appId: '1:487039653770:ios:4332c1e4a182147c209a73',
    messagingSenderId: '487039653770',
    projectId: 'basil-woods-activitymanagement',
    storageBucket: 'basil-woods-activitymanagement.firebasestorage.app',
    iosBundleId: 'com.example.iskconActivityManagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBP-RdyDlk5kVhbgpPqkPx-TWPbVS5nDZE',
    appId: '1:487039653770:web:cb47aec325454b78209a73',
    messagingSenderId: '487039653770',
    projectId: 'basil-woods-activitymanagement',
    authDomain: 'basil-woods-activitymanagement.firebaseapp.com',
    storageBucket: 'basil-woods-activitymanagement.firebasestorage.app',
  );

}