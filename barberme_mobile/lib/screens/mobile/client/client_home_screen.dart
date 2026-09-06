import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/shop_settings.dart';
import '../../../models/shop_working_hours.dart';
import '../../../services/notification_service.dart';
import '../../../services/shop_service.dart';
import '../../../services/signalr_notification_service.dart';
import '../../../services/recommendation_service.dart';

import 'booking/select_barber_screen.dart';
import 'notifications_screen.dart';
import 'recommendations_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() =>
      _ClientHomeScreenState();
}

class _ClientHomeScreenState
    extends State<ClientHomeScreen> {
  final ShopService _shopService =
      ShopService();

  final NotificationService _notificationService =
      NotificationService();

  final SignalRNotificationService
      _signalRNotificationService =
      SignalRNotificationService();
  
  final RecommendationService _recommendationService =
    RecommendationService();

  ShopSettings? _shopSettings;
  List<ShopWorkingHours> _workingHours = [];

  int _unreadNotificationCount = 0;

  bool _isLoading = true;
  String? _errorMessage;

  bool _hasRecommendations = false;

  @override
  void initState() {
    super.initState();

    _loadShopData();
    _loadUnreadNotificationCount();
    _loadRecommendationsAvailability();
    _connectSignalR();
  }

  @override
  void dispose() {
    _signalRNotificationService.disconnect();

    super.dispose();
  }

  Future<void> _loadShopData() async {
    try {
      final settings =
          await _shopService.getShopSettings();

      final workingHours =
          await _shopService.getWorkingHours();

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
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoading = false;
      });
    }
  }

  Future<void>
      _loadUnreadNotificationCount() async {
    try {
      final count =
          await _notificationService
              .getUnreadCount();

      if (!mounted) return;

      setState(() {
        _unreadNotificationCount = count;
      });
    } catch (_) {
      // Notification badge is not essential
      // for the Home screen.
    }
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      _loadShopData(),
      _loadUnreadNotificationCount(),
      _loadRecommendationsAvailability(),
    ]);
  }

  Future<void> _connectSignalR() async {
    try {
      await _signalRNotificationService.connect(
        onNotificationReceived: (data) {
          if (!mounted) return;

          _loadUnreadNotificationCount();

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                data['title']?.toString() ??
                    'New notification',
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint(
        'SignalR connection failed: $e',
      );
    }
  }

  void _showWorkingHours() {
    final now = DateTime.now();

    // Backend:
    // Sunday = 0
    // Monday = 1
    // ...
    // Saturday = 6
    final currentDay =
        now.weekday % 7;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor:
          AppTheme.backgroundColor,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              24,
              8,
              24,
              24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'Working hours',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                ..._workingHours.map(
                  (item) {
                    final isToday =
                        item.dayOfWeek ==
                            currentDay;

                    final workingTime =
                        item.isWorking
                            ? '${_formatTime(item.startTime)} - '
                                '${_formatTime(item.endTime)}'
                            : 'Closed';

                    return Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _dayName(
                                item.dayOfWeek,
                              ),
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isToday
                                        ? FontWeight
                                            .bold
                                        : FontWeight
                                            .normal,
                              ),
                            ),
                          ),

                          Text(
                            workingTime,
                            style:
                                TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isToday
                                      ? FontWeight
                                          .bold
                                      : FontWeight
                                          .normal,
                              color:
                                  item.isWorking
                                      ? AppTheme
                                          .textPrimaryColor
                                      : AppTheme
                                          .textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
      return value.substring(
        0,
        5,
      );
    }

    return value;
  }

  Future<void> _loadRecommendationsAvailability() async {
    try {
      final recommendations =
          await _recommendationService.getRecommendations();

      if (!mounted) return;

      setState(() {
        _hasRecommendations = recommendations.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasRecommendations = false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _shopSettings?.name ??
              'Barber Me',
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () async {
              await Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationsScreen(),
                ),
              );

              if (!mounted) return;

              await _loadUnreadNotificationCount();
            },
            icon: Badge(
              isLabelVisible:
                  _unreadNotificationCount >
                      0,
              label: Text(
                _unreadNotificationCount >
                        99
                    ? '99+'
                    : _unreadNotificationCount
                        .toString(),
              ),
              child: const Icon(
                Icons
                    .notifications_outlined,
              ),
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
        child:
            CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                _errorMessage!,
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 16,
              ),

              FilledButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  _refreshHome();
                },
                child:
                    const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshHome,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Book your next appointment in just a few steps.',
              style: TextStyle(
                fontSize: 15,
                color:
                    AppTheme.textSecondaryColor,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            SizedBox(
              height: 54,
              child:
                  FilledButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SelectBarberScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons
                      .calendar_month_outlined,
                ),
                label:
                    const Text(
                  'Book an appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),

            if(_hasRecommendations) ...[
              const SizedBox(
                height: 12,
              ),

              SizedBox(
                height: 50,
                child:OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const RecommendationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons
                        .auto_awesome_outlined,
                  ),
                  label:
                      const Text(
                    'Recommended for you',
                  ),
                ),
              ),
            ],
            
            const SizedBox(
              height: 32,
            ),

            const Text(
              'Barbershop information',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _InfoCard(
              icon:
                  Icons.access_time,
              title:
                  'Working hours',
              value:
                  'View weekly schedule',
              onTap:
                  _showWorkingHours,
            ),

            const SizedBox(
              height: 12,
            ),

            _InfoCard(
              icon: Icons
                  .location_on_outlined,
              title: 'Address',
              value:
                  _shopSettings
                          ?.address ??
                      'Not configured',
            ),

            const SizedBox(
              height: 12,
            ),

            _InfoCard(
              icon:
                  Icons.phone_outlined,
              title: 'Phone',
              value:
                  _shopSettings
                          ?.phoneNumber ??
                      'Not configured',
            ),

            if (_shopSettings
                    ?.email
                    .isNotEmpty ==
                true) ...[
              const SizedBox(
                height: 12,
              ),

              _InfoCard(
                icon:
                    Icons.email_outlined,
                title: 'Email',
                value:
                    _shopSettings!.email,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(
            18,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color: AppTheme
                      .accentColor
                      .withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppTheme
                      .accentColor,
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        color: AppTheme
                            .textSecondaryColor,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      value,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                const Icon(
                  Icons
                      .chevron_right,
                  color: AppTheme
                      .textSecondaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}