import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final stripePublishableKey =
      dotenv.env['STRIPE_PUBLISHABLE_KEY'];

  if (stripePublishableKey == null ||
      stripePublishableKey.isEmpty) {
    throw Exception(
      'STRIPE_PUBLISHABLE_KEY is missing from .env.',
    );
  }

  Stripe.publishableKey = stripePublishableKey;

  await Stripe.instance.applySettings();

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