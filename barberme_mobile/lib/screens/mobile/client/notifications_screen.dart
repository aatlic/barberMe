import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/notification.dart';
import '../../../services/notification_service.dart';
import '../../../services/signalr_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final NotificationService _notificationService =
      NotificationService();

  final SignalRNotificationService
    _signalRNotificationService =
    SignalRNotificationService();

  static const int _pageSize = 20;

  List<AppNotification> _notifications = [];

  int _page = 1;
  int _totalCount = 0;

  bool _isLoading = true;
  bool _isLoadingMore = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadNotifications(
      refresh: true,
    );

    _connectSignalR();
  }

  Future<void> _loadNotifications({
    required bool refresh,
  }) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
      });
    } else {
      if (_isLoadingMore) {
        return;
      }

      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final page = refresh
          ? 1
          : _page + 1;

      final result =
          await _notificationService.getNotifications(
        page: page,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _notifications = result.items;
        } else {
          _notifications.addAll(
            result.items,
          );
        }

        _page = result.page;
        _totalCount = result.totalCount;

        _isLoading = false;
        _isLoadingMore = false;
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
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _markAsRead(
    AppNotification notification,
  ) async {
    if (notification.isRead) {
      return;
    }

    try {
      await _notificationService.markAsRead(
        notification.id,
      );

      if (!mounted) return;

      setState(() {
        final index = _notifications.indexWhere(
          (item) => item.id == notification.id,
        );

        if (index == -1) {
          return;
        }

        final old = _notifications[index];

        _notifications[index] =
            AppNotification(
          id: old.id,
          userId: old.userId,
          notificationTypeId:
              old.notificationTypeId,
          notificationTypeName:
              old.notificationTypeName,
          title: old.title,
          text: old.text,
          isRead: true,
          createdAt: old.createdAt,
          readAt: DateTime.now(),
        );
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  String _formatDateTime(
    DateTime value,
  ) {
    final day =
        value.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        value.month.toString().padLeft(
              2,
              '0',
            );

    final hour =
        value.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        value.minute.toString().padLeft(
              2,
              '0',
            );

    return '$day.$month.${value.year}. '
        '$hour:$minute';
  }

  IconData _getNotificationIcon(
    AppNotification notification,
  ) {
    final type =
        notification.notificationTypeName
            .toLowerCase();

    if (type.contains('reservation') ||
        type.contains('appointment')) {
      return Icons.calendar_month_outlined;
    }

    if (type.contains('payment')) {
      return Icons.payments_outlined;
    }

    if (type.contains('reminder')) {
      return Icons.alarm_outlined;
    }

    if (type.contains('promotion') ||
        type.contains('news')) {
      return Icons.campaign_outlined;
    }

    return Icons.notifications_outlined;
  }

  Future<void> _connectSignalR() async {
    try {
      await _signalRNotificationService.connect(
        onNotificationReceived: (data) async {
          if (!mounted) return;

          await _loadNotifications(
            refresh: true,
          );
        },
      );
    } catch (e) {
      debugPrint(
        'SignalR notifications connection failed: $e',
      );
    }
  }

  @override
  void dispose() {
    _signalRNotificationService.disconnect();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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

    if (_errorMessage != null &&
        _notifications.isEmpty) {
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
                  _loadNotifications(
                    refresh: true,
                  );
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

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () {
          return _loadNotifications(
            refresh: true,
          );
        },
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(
            24,
          ),
          children: const [
            SizedBox(
              height: 140,
            ),

            Icon(
              Icons.notifications_none,
              size: 64,
              color:
                  AppTheme.textSecondaryColor,
            ),

            SizedBox(
              height: 16,
            ),

            Text(
              'No notifications yet.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            SizedBox(
              height: 6,
            ),

            Text(
              'Your notifications will appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    final hasMore =
        _notifications.length <
            _totalCount;

    return RefreshIndicator(
      onRefresh: () {
        return _loadNotifications(
          refresh: true,
        );
      },
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24,
        ),
        itemCount:
            _notifications.length +
                (hasMore ? 1 : 0),
        separatorBuilder: (
          _,
          __,
        ) =>
            const SizedBox(
          height: 10,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          if (index ==
              _notifications.length) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: _isLoadingMore
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: () {
                          _loadNotifications(
                            refresh: false,
                          );
                        },
                        child:
                            const Text(
                          'Load more',
                        ),
                      ),
              ),
            );
          }

          final notification =
              _notifications[index];

          return _NotificationCard(
            notification:
                notification,
            formattedDate:
                _formatDateTime(
              notification.createdAt,
            ),
            icon:
                _getNotificationIcon(
              notification,
            ),
            onTap: () {
              _markAsRead(
                notification,
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard
    extends StatelessWidget {
  final AppNotification notification;
  final String formattedDate;
  final IconData icon;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.formattedDate,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isUnread =
        !notification.isRead;

    return Material(
      color: isUnread
          ? AppTheme.accentColor
              .withValues(
              alpha: 0.07,
            )
          : Colors.white,
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color: AppTheme
                      .accentColor
                      .withValues(
                    alpha: 0.12,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppTheme
                      .accentColor,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Expanded(
                          child: Text(
                            notification
                                .title,
                            style:
                                TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isUnread
                                      ? FontWeight
                                          .bold
                                      : FontWeight
                                          .w600,
                            ),
                          ),
                        ),

                        if (isUnread)
                          Container(
                            margin:
                                const EdgeInsets.only(
                              left: 8,
                              top: 5,
                            ),
                            width: 8,
                            height: 8,
                            decoration:
                                const BoxDecoration(
                              color: AppTheme
                                  .accentColor,
                              shape: BoxShape
                                  .circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      notification.text,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        color: AppTheme
                            .textSecondaryColor,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      formattedDate,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color: AppTheme
                            .textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}