import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'navigation/routes.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ISKCONApp());
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
