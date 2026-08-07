import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const BarberMeApp());
}

class BarberMeApp extends StatelessWidget {
  const BarberMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber Me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}