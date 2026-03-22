import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'navigation/routes.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  runApp(const ISKCONApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Enable Firestore offline persistence
    FirestoreService.enableOfflinePersistence();
  } catch (_) {
    // Firebase not configured yet – app continues with mock data.
  }
}

class ISKCONApp extends StatelessWidget {
  const ISKCONApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const LoginScreen(),
    );
  }
}
