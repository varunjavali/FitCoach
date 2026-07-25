import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const FitCoachApp());
}

class FitCoachApp extends StatelessWidget {
  const FitCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FitCoach",
      theme: AppTheme.lightTheme,
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginScreen(),
        "/dashboard": (context) => const DashboardScreen(),
      },
    );
  }
}