import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/shop_settings.dart';
import '../../../models/shop_working_hours.dart';
import '../../../services/shop_service.dart';

import 'booking/select_barber_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ShopService _shopService = ShopService();

  ShopSettings? _shopSettings;
  List<ShopWorkingHours> _workingHours = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    try {
      final settings = await _shopService.getShopSettings();
      final workingHours = await _shopService.getWorkingHours();

      if (!mounted) return;

      setState(() {
        _shopSettings = settings;
        _workingHours = workingHours;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showWorkingHours() {
    final now = DateTime.now();
    final currentDay = now.weekday % 7;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppTheme.backgroundColor,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              8,
              24,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Working hours',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ..._workingHours.map((item) {
                  final isToday = item.dayOfWeek == currentDay;

                  final workingTime = item.isWorking
                      ? '${_formatTime(item.startTime)} - '
                          '${_formatTime(item.endTime)}'
                      : 'Closed';

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dayName(item.dayOfWeek),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          workingTime,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: item.isWorking
                                ? AppTheme.textPrimaryColor
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _dayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }

  String _formatTime(String value) {
    if (value.length >= 5) {
      return value.substring(0, 5);
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _shopSettings?.name ?? 'Barber Me',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Notifications screen will be added later.
            },
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  _loadShopData();
                },
                child: const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadShopData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            const Text(
              'Book your next appointment in just a few steps.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SelectBarberScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.calendar_month_outlined,
                ),
                label: const Text(
                  'Book an appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Barbershop information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _InfoCard(
              icon: Icons.access_time,
              title: 'Working hours',
              value: 'View weekly schedule',
              onTap: _showWorkingHours,
            ),

            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.location_on_outlined,
              title: 'Address',
              value: _shopSettings?.address ??
                  'Not configured',
            ),

            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: _shopSettings?.phoneNumber ??
                  'Not configured',
            ),

            if (_shopSettings?.email.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: _shopSettings!.email,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentColor,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color:
                            AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}