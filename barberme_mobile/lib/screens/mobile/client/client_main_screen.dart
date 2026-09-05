import 'package:flutter/material.dart';

import 'client_appointments_screen.dart';
import 'client_home_screen.dart';
import 'client_profile_screen.dart';

class ClientMainScreen extends StatefulWidget {
  final int initialIndex;
  final int? recommendationIdToRate;

  const ClientMainScreen({
    super.key,
    this.initialIndex = 0,
    this.recommendationIdToRate,
  });

  @override
  State<ClientMainScreen> createState() =>
      _ClientMainScreenState();
}

class _ClientMainScreenState
    extends State<ClientMainScreen> {
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
      const ClientHomeScreen(),

      ClientAppointmentsScreen(
        recommendationIdToRate:
            widget.recommendationIdToRate,
      ),

      const ClientProfileScreen(),
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