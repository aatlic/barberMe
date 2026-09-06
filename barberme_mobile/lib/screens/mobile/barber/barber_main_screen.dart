import 'package:flutter/material.dart';

import 'barber_home_screen.dart';
import 'barber_appointments_screen.dart';
import 'barber_profile_screen.dart';

class BarberMainScreen extends StatefulWidget {
  final int initialIndex;

  const BarberMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<BarberMainScreen> createState() =>
      _BarberMainScreenState();
}

class _BarberMainScreenState
    extends State<BarberMainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const BarberHomeScreen(),
      const BarberAppointmentsScreen(),
      const BarberProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected:
            _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
            ),
            selectedIcon: Icon(
              Icons.calendar_month,
            ),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}