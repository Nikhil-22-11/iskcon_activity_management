# ISKCON Activity Management

ISKCON School After Pre-School Activities Management System

## Firebase Setup

This project uses **Firebase Firestore** as its database.

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project named `basil-woods-activitymanagement`
3. Enable **Firestore Database** (start in test mode for development)
4. Enable **Authentication → Email/Password**

### Step 2: Register Your Flutter App

1. In Firebase Console → Project Settings → Your Apps → Add App → Flutter
2. Follow the **FlutterFire CLI** setup:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=basil-woods-activitymanagement
```

This overwrites `flutter_app/lib/firebase_options.dart` with real API keys.

**Or** manually update `lib/firebase_options.dart` by replacing every `YOUR_*_API_KEY`
placeholder with values from your Firebase project settings.

### Step 3: Android

Download `google-services.json` from Firebase Console and place it at:
```
flutter_app/android/app/google-services.json
```

### Step 4: iOS

Download `GoogleService-Info.plist` from Firebase Console and place it at:
```
flutter_app/ios/Runner/GoogleService-Info.plist
```

### Step 5: Run the app

```bash
cd flutter_app
flutter pub get
flutter run
```

## Running Without Firebase (Mock Mode)

The app works offline with mock data automatically when Firebase is not
configured. All credentials and data fall back to the built-in mock service.

**Default credentials:**

| Role       | Email                    | Password     |
|------------|--------------------------|--------------|
| Guard      | guard@iskcon.org         | Guard123     |
| Teacher    | teacher@iskcon.org       | Teacher123   |
| Principal  | principal@iskcon.org     | Principal123 |

## Features

- **Guard Dashboard** – QR scan attendance, real-time check-in history
- **Teacher Dashboard** – Activity management, student enrollments
- **Principal Dashboard** – Analytics, admission forms, Excel export
- **Admission Form** – Saved to Firestore in real time
- **Excel Export** – Students, Attendance, Financial reports

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `PlatformException: Failed to load FirebaseApp` | Replace placeholder keys in `firebase_options.dart` |
| Firestore permission denied | Set Firestore rules to test mode or update security rules |
| App runs on mock data only | Firebase not initialised – follow setup steps above |
