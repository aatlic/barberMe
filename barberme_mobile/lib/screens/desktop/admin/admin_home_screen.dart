import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_screen.dart';
import 'admin_users_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() =>
      _AdminHomeScreenState();
}

class _AdminHomeScreenState
    extends State<AdminHomeScreen> {
  final AuthService _authService = AuthService();

  int _selectedIndex = 0;
  bool _isLoggingOut = false;

  final List<_AdminMenuItem> _menuItems = const [
    _AdminMenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _AdminMenuItem(
      title: 'Users',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    _AdminMenuItem(
      title: 'Barbers',
      icon: Icons.content_cut_outlined,
      selectedIcon: Icons.content_cut,
    ),
    _AdminMenuItem(
      title: 'Services',
      icon: Icons.design_services_outlined,
      selectedIcon: Icons.design_services,
    ),
    _AdminMenuItem(
      title: 'Appointments',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
    ),
    _AdminMenuItem(
      title: 'Working Hours',
      icon: Icons.schedule_outlined,
      selectedIcon: Icons.schedule,
    ),
    _AdminMenuItem(
      title: 'Reports',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
    ),
    _AdminMenuItem(
      title: 'News',
      icon: Icons.article_outlined,
      selectedIcon: Icons.article,
    ),
    _AdminMenuItem(
      title: 'Support',
      icon: Icons.support_agent_outlined,
      selectedIcon: Icons.support_agent,
    ),
  ];

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    await _authService.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: AppTheme.primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildLogoSection(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: _menuItems.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  return _buildMenuItem(
                    item: _menuItems[index],
                    index: index,
                  );
                },
              ),
            ),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.content_cut,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Barber Me',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Administration',
                style: TextStyle(
                  color: Color(0xFFB8B8B8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required _AdminMenuItem item,
    required int index,
  }) {
    final isSelected =
        _selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentColor
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? item.selectedIcon
                    : item.icon,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFFC8C8C8),
                size: 21,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(
                            0xFFE0E0E0,
                          ),
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        20,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              _isLoggingOut ? null : _logout,
          borderRadius:
              BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            child: Row(
              children: [
                _isLoggingOut
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.logout,
                        color:
                            Color(0xFFC8C8C8),
                        size: 21,
                      ),
                const SizedBox(width: 14),
                Text(
                  _isLoggingOut
                      ? 'Logging out...'
                      : 'Log out',
                  style: const TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();

      case 1:
        return const AdminUsersScreen();

      default:
        return _buildPlaceholder(
          _menuItems[_selectedIndex],
        );
    }
  }

  Widget _buildDashboard() {
    return Container(
      color: AppTheme.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1250,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildPageHeader(
                  title: 'Dashboard',
                  subtitle:
                      'Manage Barber Me from one place.',
                ),
                const SizedBox(height: 32),
                _buildWelcomeCard(),
                const SizedBox(height: 32),
                const Text(
                  'Quick access',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color:
                        AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickAccessGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader({
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color:
                      AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color:
                      AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color:
                  const Color(0xFFE5E1DC),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor:
                    AppTheme.primaryColor,
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Administrator',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Barber Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Use the administration panel to manage users, barbers, services, appointments and other system data.',
                  style: TextStyle(
                    color: Color(0xFFD0D0D0),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        AppTheme.accentColor,
                    foregroundColor:
                        Colors.white,
                  ),
                  icon: const Icon(
                    Icons.calendar_month,
                    size: 19,
                  ),
                  label: const Text(
                    'View appointments',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.content_cut,
              color: AppTheme.accentColor,
              size: 52,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final items = [
      const _QuickAccessItem(
        title: 'Users',
        subtitle:
            'Manage system users',
        icon: Icons.people_outline,
        menuIndex: 1,
      ),
      const _QuickAccessItem(
        title: 'Barbers',
        subtitle:
            'Manage barber profiles',
        icon: Icons.content_cut,
        menuIndex: 2,
      ),
      const _QuickAccessItem(
        title: 'Services',
        subtitle:
            'Manage salon services',
        icon: Icons.design_services_outlined,
        menuIndex: 3,
      ),
      const _QuickAccessItem(
        title: 'Appointments',
        subtitle:
            'Review all appointments',
        icon: Icons.calendar_month_outlined,
        menuIndex: 4,
      ),
      const _QuickAccessItem(
        title: 'Working Hours',
        subtitle:
            'Manage barber schedules',
        icon: Icons.schedule_outlined,
        menuIndex: 5,
      ),
      const _QuickAccessItem(
        title: 'Reports',
        subtitle:
            'Generate business reports',
        icon: Icons.bar_chart_outlined,
        menuIndex: 6,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;

        if (constraints.maxWidth < 850) {
          crossAxisCount = 2;
        }

        if (constraints.maxWidth < 550) {
          crossAxisCount = 1;
        }

        const spacing = 16.0;

        final itemWidth =
            (constraints.maxWidth -
                    spacing *
                        (crossAxisCount - 1)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _buildQuickAccessCard(
                item,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickAccessCard(
    _QuickAccessItem item,
  ) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex =
                item.menuIndex;
          });
        },
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color:
                  const Color(0xFFE5E1DC),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor
                      .withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color:
                      AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color: AppTheme
                            .textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme
                            .textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFAAAAAA),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(
    _AdminMenuItem item,
  ) {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1250,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildPageHeader(
                title: item.title,
                subtitle:
                    'Barber Me administration',
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'This section will be implemented next.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme
                          .textSecondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const _AdminMenuItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}

class _QuickAccessItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final int menuIndex;

  const _QuickAccessItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.menuIndex,
  });
}