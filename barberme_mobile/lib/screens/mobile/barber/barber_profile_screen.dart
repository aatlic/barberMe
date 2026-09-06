import 'package:flutter/material.dart';

class BarberProfileScreen extends StatelessWidget {
  const BarberProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Barber profile',
        ),
      ),
    );
  }
}