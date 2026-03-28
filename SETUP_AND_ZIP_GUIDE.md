# ISKCON Activity Management — Setup & ZIP Guide

A beginner-friendly, copy-paste guide to get the project running on **any device** (Windows / macOS / Linux) and to download a ready-to-use ZIP of the Flutter app.

---

## Table of Contents

1. [Prerequisites Checklist](#1-prerequisites-checklist)
2. [Clone the Repository](#2-clone-the-repository)
3. [Install Dependencies](#3-install-dependencies)
4. [Run the App](#4-run-the-app)
   - [Windows Desktop](#41-run-on-windows-desktop)
   - [Android Emulator](#42-run-on-android-emulator)
   - [Physical Android Device](#43-run-on-a-physical-android-device)
5. [Download a ZIP of the Project](#5-download-a-zip-of-the-project)
   - [Manual ZIP from GitHub](#51-manual-zip-from-github)
   - [Automated ZIP via GitHub Actions](#52-automated-zip-via-github-actions)
6. [Firebase Setup (Future Integration)](#6-firebase-setup-future-integration)
7. [Excel Export Setup](#7-excel-export-setup)
8. [Troubleshooting Guide](#8-troubleshooting-guide)

---

## 1. Prerequisites Checklist

Complete **all** items below before running the project.

### Every Platform

| Tool | Minimum Version | Download Link | Notes |
|------|----------------|---------------|-------|
| **Flutter SDK** | 3.10+ | https://docs.flutter.dev/get-started/install | Choose your OS tab |
| **Dart SDK** | included with Flutter | — | Bundled with Flutter |
| **Git** | any | https://git-scm.com/downloads | Required to clone |
| **Android Studio** | 2022.x+ | https://developer.android.com/studio | Needed for Android emulator |
| **Android SDK** | API 33+ | Inside Android Studio | Install via SDK Manager |
| **Java JDK** | 17 | https://adoptium.net/ | Required by Android build tools |

### Windows Only (for Windows desktop target)

| Tool | Notes |
|------|-------|
| **Visual Studio 2022** with "Desktop development with C++" workload | Required for `flutter run -d windows` |

### macOS Only (for iOS target — optional)

| Tool | Notes |
|------|-------|
| **Xcode 14+** | From Mac App Store |
| **CocoaPods** | `sudo gem install cocoapods` |

### Verify Installation

Run these commands in a terminal. All should print version numbers — no errors.

```bash
flutter --version
dart --version
git --version
java --version
```

Run Flutter's built-in check (fix anything marked **[✗]**):

```bash
flutter doctor -v
```

---

## 2. Clone the Repository

Open a terminal and run:

```bash
# Clone the repo
git clone https://github.com/Nikhil-22-11/iskcon_activity_management.git

# Enter the Flutter app folder
cd iskcon_activity_management/flutter_app
```

> **Windows users:** Use **Git Bash**, **PowerShell**, or **Windows Terminal** — all work fine.

---

## 3. Install Dependencies

Inside the `flutter_app` folder, run:

```bash
flutter pub get
```

Expected output ends with something like:

```
Changed 0 dependencies!
```

> If you see errors, run `flutter doctor -v` and fix any issues it reports first.

---

## 4. Run the App

### 4.1 Run on Windows Desktop

```bash
# From inside flutter_app/
flutter run -d windows
```

The app window opens on your desktop. Hot-reload works with the **r** key.

### 4.2 Run on Android Emulator

**Step 1 — Create an emulator in Android Studio**

1. Open Android Studio → **Tools → Device Manager**
2. Click **Create Device**
3. Choose **Pixel 6** (or any phone) → Next
4. Select system image **API 33** (download if needed) → Next → Finish
5. Press the **▶ Play** button next to the device to start it

**Step 2 — Launch the app on the emulator**

```bash
# Confirm the emulator is detected
flutter devices

# Run on the emulator (replace <device-id> with what flutter devices showed)
flutter run -d <device-id>

# Or let Flutter pick the only available device automatically
flutter run
```

### 4.3 Run on a Physical Android Device

1. On the phone: **Settings → About Phone → tap "Build number" 7 times** (enables developer mode)
2. **Settings → Developer Options → USB Debugging → Enable**
3. Connect phone via USB cable
4. Accept the "Allow USB Debugging" prompt on the phone
5. Run:

```bash
flutter devices        # Your phone should appear
flutter run            # Installs and launches the app
```

---

## 5. Download a ZIP of the Project

### 5.1 Manual ZIP from GitHub

1. Go to: **https://github.com/Nikhil-22-11/iskcon_activity_management**
2. Click the green **Code** button
3. Click **Download ZIP**
4. Extract the ZIP on the target device
5. Open a terminal inside `iskcon_activity_management-main/flutter_app/`
6. Run:

```bash
flutter pub get
flutter run
```

### 5.2 Automated ZIP via GitHub Actions

A workflow is included at `.github/workflows/zip-flutter-app.yml` that automatically builds a downloadable ZIP artifact of the `flutter_app` source every time you push to `main` (or manually trigger it).

**How to download the artifact:**

1. Go to **https://github.com/Nikhil-22-11/iskcon_activity_management/actions**
2. Click the **"Build & Package Flutter App ZIP"** workflow
3. Click the most recent successful run
4. Scroll down to **Artifacts**
5. Click **flutter-app-source** to download the ZIP

**How to manually trigger the workflow:**

1. Go to the Actions tab → **"Build & Package Flutter App ZIP"**
2. Click **"Run workflow"** → **"Run workflow"** (green button)
3. Download the artifact as above once it completes (~1 minute)

---

## 6. Firebase Setup (Future Integration)

> **Note:** The app currently uses mock/in-memory data. Follow these steps when you are ready to connect a real Firebase database.

### Step 1 — Create a Firebase Project

1. Go to **https://console.firebase.google.com/**
2. Click **"Add project"** → Enter name (e.g., `iskcon-activity-mgmt`) → Continue
3. Disable Google Analytics for now → **Create project**

### Step 2 — Enable Firestore

1. In the Firebase console, go to **Build → Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (change rules before production)
4. Select a region close to you → **Enable**

### Step 3 — Add Flutter App to Firebase (using FlutterFire CLI)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# From inside flutter_app/
flutterfire configure --project=<your-firebase-project-id>
```

This generates `lib/firebase_options.dart` automatically.

### Step 4 — Add Firebase packages

```bash
flutter pub add firebase_core
flutter pub add cloud_firestore
flutter pub add firebase_auth
flutter pub get
```

Or manually add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.0
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.16.0
```

### Step 5 — Initialize Firebase in `main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### Suggested Firestore Collections

| Collection | Documents contain |
|------------|------------------|
| `students` | name, dob, school, contact, paymentStatus |
| `activities` | title, date, time, teacherId, maxEnrollments |
| `enrollments` | studentId, activityId, enrolledAt |
| `attendance` | studentId, activityId, scannedAt, scannedBy |
| `admissions` | all admission form fields + timestamp |
| `payments` | studentId, amount, mode, period, transactionId |

### Firebase Pricing Summary

| Plan | Cost | Reads/day | Writes/day | Storage |
|------|------|-----------|-----------|---------|
| Spark (free) | $0 | 50,000 | 20,000 | 1 GB |
| Blaze (pay-as-you-go) | ~$5–10/month for 500 students | Unlimited | Unlimited | Pay per GB |

> For 500 students + daily active use, the **Blaze plan** (~$5–10/month) is recommended for production.

---

## 7. Excel Export Setup

> The app will gain an Excel export button (in Principal/Teacher/Guard dashboards) once this package is added.

### Step 1 — Add the `excel` package

```bash
flutter pub add excel
flutter pub get
```

Or in `pubspec.yaml`:

```yaml
dependencies:
  excel: ^4.0.2
```

### Step 2 — Add file saving support

```bash
flutter pub add path_provider
flutter pub add permission_handler
flutter pub get
```

### Step 3 — Export example (copy-paste snippet)

```dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

Future<void> exportStudentsToExcel(List<Map<String, dynamic>> students) async {
  final excel = Excel.createExcel();
  final sheet = excel['Students'];

  // Header row
  sheet.appendRow(['Name', 'DOB', 'School', 'Payment Status', 'Enrolled At']);

  // Data rows
  for (final s in students) {
    sheet.appendRow([
      s['name'],
      s['dob'],
      s['school'],
      s['paymentStatus'],
      s['enrolledAt'],
    ]);
  }

  // Save to device
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/students_export.xlsx';
  final fileBytes = excel.save();
  if (fileBytes != null) {
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);
    print('Excel saved to $filePath');
  }
}
```

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml` (inside `<manifest>`):

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

For Android 10+, add inside `<application>`:

```xml
android:requestLegacyExternalStorage="true"
```

### Windows / macOS — No Permissions Needed

`getApplicationDocumentsDirectory()` works without extra permissions on desktop.

---

## 8. Troubleshooting Guide

### `flutter: command not found`

**Cause:** Flutter SDK is not in your PATH.

```bash
# Add to ~/.bashrc (Linux/macOS) or System Environment Variables (Windows):
export PATH="$PATH:/path/to/flutter/bin"

# Reload shell
source ~/.bashrc   # or restart terminal

# Verify
flutter --version
```

### `flutter doctor` reports Android SDK not found

```bash
# Inside Android Studio:
# Tools → SDK Manager → SDK Platforms → install API 33
# Tools → SDK Manager → SDK Tools → install "Android SDK Build-Tools 33"

# Then accept licenses:
flutter doctor --android-licenses
```

### `flutter pub get` fails with network errors

```bash
# Set Flutter mirror (useful in restricted networks):
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get
```

### Emulator not showing in `flutter devices`

1. Make sure the emulator is **running** in Android Studio (you should see it in Device Manager with a green icon)
2. Run `flutter emulators` to list available emulators
3. Launch one with: `flutter emulators --launch <emulator-id>`
4. Wait ~30 seconds for it to boot, then run `flutter devices` again

### `Gradle build failed` on Android

```bash
cd android
./gradlew clean    # Linux/macOS
gradlew.bat clean  # Windows

cd ..
flutter run
```

### `MissingPluginException` at runtime

```bash
flutter clean
flutter pub get
flutter run
```

### `No toolchain found` on Windows (for Windows desktop)

Install **Visual Studio 2022** with the **"Desktop development with C++"** workload:
- Download: https://visualstudio.microsoft.com/downloads/
- During install, check ✅ **Desktop development with C++**

### `CocoaPods not installed` on macOS

```bash
sudo gem install cocoapods
pod setup
```

### App crashes on launch (Firebase not initialized)

If you added Firebase packages but haven't configured them:

```bash
# Run FlutterFire configure again:
flutterfire configure --project=<your-firebase-project-id>
```

Or temporarily revert to mock data service until Firebase is ready.

---

## Quick-Start Summary (copy-paste)

```bash
# 1. Clone
git clone https://github.com/Nikhil-22-11/iskcon_activity_management.git
cd iskcon_activity_management/flutter_app

# 2. Install dependencies
flutter pub get

# 3a. Run on Windows desktop
flutter run -d windows

# 3b. Run on Android emulator (start emulator in Android Studio first)
flutter run

# 4. Check for issues
flutter doctor -v
```

---

*Generated for ISKCON Activity Management System — Flutter App v1.0.0*
