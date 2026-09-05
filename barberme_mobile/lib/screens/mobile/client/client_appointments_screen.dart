import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

import '../../../core/theme/app_theme.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import '../../../services/payment_service.dart';
import '../../../services/review_service.dart';
import 'appointments/reschedule_appointment_screen.dart';
import 'appointment_details_screen.dart';

class ClientAppointmentsScreen extends StatefulWidget {
  const ClientAppointmentsScreen({super.key});

  @override
  State<ClientAppointmentsScreen> createState() =>
      _ClientAppointmentsScreenState();
}

class _ClientAppointmentsScreenState
    extends State<ClientAppointmentsScreen> {
  final AppointmentService _appointmentService =
      AppointmentService();

  final PaymentService _paymentService =
      PaymentService();

  final ReviewService _reviewService =
    ReviewService();

  static const int _pageSize = 20;

  int _selectedTab = 0;

  final TextEditingController _searchController =
    TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // UPCOMING
  List<Appointment> _upcomingAppointments = [];
  int _upcomingPage = 1;
  int _upcomingTotalCount = 0;
  bool _isLoadingUpcoming = true;
  bool _isLoadingMoreUpcoming = false;
  String? _upcomingErrorMessage;

  // HISTORY
  List<Appointment> _historyAppointments = [];
  int _historyPage = 1;
  int _historyTotalCount = 0;
  bool _isLoadingHistory = false;
  bool _isLoadingMoreHistory = false;
  String? _historyErrorMessage;

  // PAYMENT
  int? _payingAppointmentId;

  int? _updatingReminderAppointmentId;

  @override
  void initState() {
    super.initState();

    _loadUpcoming(
      refresh: true,
    );
  }

  Future<void> _loadUpcoming({
    required bool refresh,
  }) async {
    if (refresh) {
      setState(() {
        _isLoadingUpcoming = true;
        _upcomingErrorMessage = null;
        _upcomingPage = 1;
      });
    } else {
      if (_isLoadingMoreUpcoming) {
        return;
      }

      setState(() {
        _isLoadingMoreUpcoming = true;
      });
    }

    try {
      final page = refresh
          ? 1
          : _upcomingPage + 1;

      final result =
        await _appointmentService.getAppointments(
          listType: 'Upcoming',
          fts: _searchText,
          page: page,
          pageSize: _pageSize,
        );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _upcomingAppointments = result.items;
        } else {
          _upcomingAppointments.addAll(
            result.items,
          );
        }

        _upcomingPage = result.page;
        _upcomingTotalCount = result.totalCount;

        _isLoadingUpcoming = false;
        _isLoadingMoreUpcoming = false;
        _upcomingErrorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _upcomingErrorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoadingUpcoming = false;
        _isLoadingMoreUpcoming = false;
      });
    }
  }

  Future<void> _loadHistory({
    required bool refresh,
  }) async {
    if (refresh) {
      setState(() {
        _isLoadingHistory = true;
        _historyErrorMessage = null;
        _historyPage = 1;
      });
    } else {
      if (_isLoadingMoreHistory) {
        return;
      }

      setState(() {
        _isLoadingMoreHistory = true;
      });
    }

    try {
      final page = refresh
          ? 1
          : _historyPage + 1;

      final result =
        await _appointmentService.getAppointments(
          listType: 'History',
          fts: _searchText,
          page: page,
          pageSize: _pageSize,
        );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _historyAppointments = result.items;
        } else {
          _historyAppointments.addAll(
            result.items,
          );
        }

        _historyPage = result.page;
        _historyTotalCount = result.totalCount;

        _isLoadingHistory = false;
        _isLoadingMoreHistory = false;
        _historyErrorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _historyErrorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoadingHistory = false;
        _isLoadingMoreHistory = false;
      });
    }
  }

  Future<void> _changeTab(
    int tab,
  ) async {
    if (_selectedTab == tab) {
      return;
    }

    setState(() {
      _selectedTab = tab;
    });

    if (tab == 1 &&
        _historyAppointments.isEmpty &&
        !_isLoadingHistory) {
      await _loadHistory(
        refresh: true,
      );
    }
  }

  Future<void> _refreshCurrentTab() async {
    if (_selectedTab == 0) {
      await _loadUpcoming(
        refresh: true,
      );
    } else {
      await _loadHistory(
        refresh: true,
      );
    }
  }

  Future<void> _payAppointment(
    Appointment appointment,
  ) async {
    if (_payingAppointmentId != null) {
      return;
    }

    setState(() {
      _payingAppointmentId =
          appointment.id;
    });

    try {
      final payment =
          await _paymentService.createPayment(
        appointment.id,
      );

      if (payment.clientSecret == null ||
          payment.clientSecret!.isEmpty) {
        throw Exception(
          'Stripe client secret is missing.',
        );
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters:
            SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              payment.clientSecret!,
          merchantDisplayName:
              'Barber Me',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await _paymentService.confirmPayment(
        payment.id,
      );

      if (!mounted) return;

      await _loadUpcoming(
        refresh: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment completed successfully.',
          ),
        ),
      );
    } on StripeException catch (e) {
      if (!mounted) return;

      if (e.error.code ==
          FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment was cancelled.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.error.localizedMessage ??
                  'Payment failed.',
            ),
          ),
        );
      }
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
    } finally {
      if (mounted) {
        setState(() {
          _payingAppointmentId = null;
        });
      }
    }
  }

  Future<void> _updateReminder(
    Appointment appointment,
    bool enabled,
  ) async {
    if (_updatingReminderAppointmentId != null) {
      return;
    }

    setState(() {
      _updatingReminderAppointmentId = appointment.id;
    });

    try {
      await _appointmentService.updateReminder(
        appointmentId: appointment.id,
        reminderEnabled: enabled,
      );

      if (!mounted) return;

      await _loadUpcoming(
        refresh: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Appointment reminder enabled.'
                : 'Appointment reminder disabled.',
          ),
        ),
      );
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
    } finally {
      if (mounted) {
        setState(() {
          _updatingReminderAppointmentId = null;
        });
      }
    }
  }

  Future<void> _cancelAppointment(
    Appointment appointment,
  ) async {
    if (appointment.isPaid) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A paid appointment must be refunded before it can be cancelled.',
          ),
        ),
      );

      return;
    }

    String cancellationReason = '';

    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.cancel_outlined,
            size: 44,
          ),
          title: const Text(
            'Cancel appointment?',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter a reason for cancelling this appointment.',
              ),
              const SizedBox(height: 16),

              TextField(
                maxLength: 500,
                maxLines: 3,
                autofocus: true,
                onChanged: (value) {
                  cancellationReason = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Cancellation reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Keep appointment',
              ),
            ),

            FilledButton(
              onPressed: () {
                final trimmedReason =
                    cancellationReason.trim();

                if (trimmedReason.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  trimmedReason,
                );
              },
              child: const Text(
                'Cancel appointment',
              ),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.isEmpty) {
      return;
    }

    try {
      await _appointmentService.cancelAppointment(
        appointmentId: appointment.id,
        cancellationReason: reason,
      );

      if (!mounted) return;

      await _loadUpcoming(
        refresh: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Appointment cancelled successfully.',
          ),
        ),
      );
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

  Future<void> _leaveReview(
    Appointment appointment,
  ) async {
    int selectedRating = 0;
    String comment = '';

    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              icon: const Icon(
                Icons.star_outline,
                size: 44,
              ),
              title: const Text(
                'Leave a review',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.serviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    appointment.barberFullName,
                    style: const TextStyle(
                      color:
                          AppTheme.textSecondaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        final rating = index + 1;

                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = rating;
                            });
                          },
                          icon: Icon(
                            rating <= selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color:
                                AppTheme.accentColor,
                            size: 34,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    maxLength: 1000,
                    maxLines: 4,
                    onChanged: (value) {
                      comment = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                      hintText:
                          'Tell us about your experience',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(false);
                  },
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: selectedRating == 0
                      ? null
                      : () {
                          Navigator.of(
                            dialogContext,
                          ).pop(true);
                        },
                  child: const Text(
                    'Submit review',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true) {
      return;
    }

    try {
      await _reviewService.createReview(
        appointmentId: appointment.id,
        rating: selectedRating,
        comment: comment,
      );

      if (!mounted) return;

      await _loadHistory(
        refresh: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thank you for your review.',
          ),
        ),
      );
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

  bool _canPay(
    Appointment appointment,
  ) {
    if (appointment.isPaid) {
      return false;
    }

    final status =
        appointment.status.toLowerCase();

    if (status == 'cancelled' ||
        status == 'completed' ||
        status == 'no show' ||
        status == 'noshow') {
      return false;
    }

    return appointment.startDateTime
        .isAfter(DateTime.now());
  }

  bool _canReschedule(
    Appointment appointment,
  ) {
    final status =
        appointment.status.toLowerCase();

    if (!appointment.startDateTime
        .isAfter(DateTime.now())) {
      return false;
    }

    return status == 'pending' ||
        status == 'confirmed';
  }

  bool _canCancel(
    Appointment appointment,
  ) {
    final status =
        appointment.status.toLowerCase();

    if (appointment.isPaid) {
      return false;
    }

    if (!appointment.startDateTime
        .isAfter(DateTime.now())) {
      return false;
    }

    return status == 'pending' ||
        status == 'confirmed';
  }

  bool _canReview(
    Appointment appointment,
  ) {
    return appointment.status
                .toLowerCase() ==
            'completed' &&
        !appointment.hasReview;
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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearch(),

          _buildTabs(),

          Expanded(
            child: _selectedTab == 0
                ? _buildUpcoming()
                : _buildHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        0,
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by barber or service',
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchText = '';
                    });

                    _refreshCurrentTab();
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onSubmitted: (value) {
          setState(() {
            _searchText = value.trim();
          });

          _refreshCurrentTab();
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        8,
      ),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment<int>(
              value: 0,
              icon: Icon(
                Icons.event_available_outlined,
              ),
              label: Text(
                'Upcoming',
              ),
            ),
            ButtonSegment<int>(
              value: 1,
              icon: Icon(
                Icons.history,
              ),
              label: Text(
                'History',
              ),
            ),
          ],
          selected: {
            _selectedTab,
          },
          onSelectionChanged: (
            selection,
          ) {
            _changeTab(
              selection.first,
            );
          },
        ),
      ),
    );
  }

  Widget _buildUpcoming() {
    if (_isLoadingUpcoming) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_upcomingErrorMessage != null &&
        _upcomingAppointments.isEmpty) {
      return _buildError(
        message:
            _upcomingErrorMessage!,
        onRetry: () {
          _loadUpcoming(
            refresh: true,
          );
        },
      );
    }

    return _buildAppointmentList(
      appointments:
          _upcomingAppointments,
      emptyIcon:
          Icons.calendar_month_outlined,
      emptyTitle:
          'No upcoming appointments.',
      emptySubtitle:
          'Your upcoming appointments will appear here.',
      isHistory: false,
      totalCount:
          _upcomingTotalCount,
      isLoadingMore:
          _isLoadingMoreUpcoming,
      onLoadMore: () {
        _loadUpcoming(
          refresh: false,
        );
      },
    );
  }

  Widget _buildHistory() {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_historyErrorMessage != null &&
        _historyAppointments.isEmpty) {
      return _buildError(
        message:
            _historyErrorMessage!,
        onRetry: () {
          _loadHistory(
            refresh: true,
          );
        },
      );
    }

    return _buildAppointmentList(
      appointments:
          _historyAppointments,
      emptyIcon:
          Icons.history,
      emptyTitle:
          'No appointment history yet.',
      emptySubtitle:
          'Completed and past appointments will appear here.',
      isHistory: true,
      totalCount:
          _historyTotalCount,
      isLoadingMore:
          _isLoadingMoreHistory,
      onLoadMore: () {
        _loadHistory(
          refresh: false,
        );
      },
    );
  }

  Widget _buildAppointmentList({
    required List<Appointment>
        appointments,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    required bool isHistory,
    required int totalCount,
    required bool isLoadingMore,
    required VoidCallback onLoadMore,
  }) {
    final hasMore =
        appointments.length <
            totalCount;

    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            _refreshCurrentTab,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(
            24,
          ),
          children: [
            const SizedBox(
              height: 120,
            ),

            Icon(
              emptyIcon,
              size: 56,
              color: AppTheme
                  .textSecondaryColor,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              emptyTitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              emptySubtitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: AppTheme
                    .textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          _refreshCurrentTab,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24,
        ),
        itemCount:
            appointments.length +
                (hasMore ? 1 : 0),
        separatorBuilder: (
          _,
          index,
        ) =>
            const SizedBox(
          height: 14,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          if (index ==
              appointments.length) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                top: 4,
                bottom: 8,
              ),
              child: Center(
                child: isLoadingMore
                    ? const Padding(
                        padding:
                            EdgeInsets.all(
                          12,
                        ),
                        child:
                            CircularProgressIndicator(),
                      )
                    : OutlinedButton(
                        onPressed:
                            onLoadMore,
                        child:
                            const Text(
                          'Load more',
                        ),
                      ),
              ),
            );
          }

          final appointment =
              appointments[index];

          return _AppointmentCard(
            appointment:
                appointment,
            formattedDate:
                _formatDateTime(
              appointment
                  .startDateTime,
            ),
            isHistory:
                isHistory,
            canPay:
                _canPay(
              appointment,
            ),
            canReschedule:
                _canReschedule(
              appointment,
            ),
            canCancel:
                _canCancel(
              appointment,
            ),
            canReview:
                _canReview(
              appointment,
            ),
            isPaying:
                _payingAppointmentId ==
                    appointment.id,
            isUpdatingReminder:
              _updatingReminderAppointmentId ==
                  appointment.id,

            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AppointmentDetailsScreen(
                    appointmentId: appointment.id,
                  ),
                ),
              );
            },

            onReminderChanged: (value) {
              _updateReminder(
                appointment,
                value,
              );
            },      
            onPay: () {
              _payAppointment(
                appointment,
              );
            },
            onReschedule: () async {
              final changed =
                  await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      RescheduleAppointmentScreen(
                    appointment: appointment,
                  ),
                ),
              );

              if (changed == true) {
                await _loadUpcoming(
                  refresh: true,
                );
              }
            },
            onCancel: () {
              _cancelAppointment(
                appointment,
              );
            },
            onReview: () {
               _leaveReview(
                appointment,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError({
    required String message,
    required VoidCallback onRetry,
  }) {
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
              message,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 16,
            ),

            FilledButton(
              onPressed: onRetry,
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
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String formattedDate;

  final bool isHistory;
  final bool canPay;
  final bool canReschedule;
  final bool canCancel;
  final bool canReview;
  final bool isPaying;
  final bool isUpdatingReminder;

  final VoidCallback onPay;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  final VoidCallback onReview;
  final ValueChanged<bool> onReminderChanged;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.formattedDate,
    required this.isHistory,
    required this.canPay,
    required this.canReschedule,
    required this.canCancel,
    required this.canReview,
    required this.isPaying,
    required this.isUpdatingReminder,
    required this.onPay,
    required this.onReschedule,
    required this.onCancel,
    required this.onReview,
    required this.onReminderChanged,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(
            18,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      appointment
                          .serviceName,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  _StatusChip(
                    status:
                        appointment.status,
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              _DetailRow(
                icon:
                    Icons.person_outline,
                text: appointment
                    .barberFullName,
              ),

              const SizedBox(
                height: 9,
              ),

              _DetailRow(
                icon:
                    Icons.schedule_outlined,
                text:
                    formattedDate,
              ),

              const SizedBox(
                height: 9,
              ),

              _DetailRow(
                icon:
                    Icons.payments_outlined,
                text:
                    '${appointment.finalPrice.toStringAsFixed(2)} BAM',
              ),

              const SizedBox(
                height: 14,
              ),

              _PaymentStatus(
                isPaid:
                    appointment.isPaid,
              ),

              if (!isHistory) ...[
                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      size: 20,
                      color: AppTheme.accentColor,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    const Expanded(
                      child: Text(
                        'Appointment reminder',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    if (isUpdatingReminder)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Switch(
                        value: appointment.reminderEnabled,
                        onChanged: onReminderChanged,
                      ),
                  ],
                ),
              ],

              if (appointment.status
                          .toLowerCase() ==
                      'cancelled' &&
                  appointment
                          .cancellationReason
                          ?.isNotEmpty ==
                      true) ...[
                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Reason: '
                  '${appointment.cancellationReason}',
                  style:
                      const TextStyle(
                    color: AppTheme
                        .textSecondaryColor,
                  ),
                ),
              ],

              if (!isHistory &&
                  (canPay ||
                      canReschedule ||
                      canCancel)) ...[
                const SizedBox(
                  height: 18,
                ),

                if (canPay)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          isPaying
                              ? null
                              : onPay,
                      icon: isPaying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.credit_card,
                            ),
                      label: Text(
                        isPaying
                            ? 'Processing...'
                            : 'Pay now',
                      ),
                    ),
                  ),

                if (canPay &&
                    (canReschedule || canCancel))
                  const SizedBox(
                    height: 10,
                  ),

                if (canReschedule || canCancel)
                  Row(
                    children: [
                      if (canReschedule)
                        Expanded(
                          child:
                              OutlinedButton.icon(
                            onPressed:
                                onReschedule,
                            icon: const Icon(
                              Icons
                                  .edit_calendar_outlined,
                            ),
                            label: const Text(
                              'Reschedule',
                            ),
                          ),
                        ),

                      if (canReschedule &&
                          canCancel)
                        const SizedBox(
                          width: 10,
                        ),

                      if (canCancel)
                        Expanded(
                          child:
                              OutlinedButton.icon(
                            onPressed:
                                onCancel,
                            icon: const Icon(
                              Icons.close,
                            ),
                            label: const Text(
                              'Cancel',
                            ),
                          ),
                        ),
                    ],
                  ),
              ],

              if (isHistory &&
                  appointment.status
                          .toLowerCase() ==
                      'completed') ...[
                const SizedBox(
                  height: 18,
                ),

                if (canReview)
                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          onReview,
                      icon:
                          const Icon(
                        Icons.star_outline,
                      ),
                      label:
                          const Text(
                        'Leave review',
                      ),
                    ),
                  )
                else if (appointment
                    .hasReview)
                  const Row(
                    children: [
                      Icon(
                        Icons
                            .check_circle_outline,
                        size: 18,
                        color:
                            Colors.green,
                      ),

                      SizedBox(
                        width: 7,
                      ),

                      Text(
                        'Reviewed',
                        style:
                            TextStyle(
                          color:
                              Colors.green,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      )
    );
  }
}

class _PaymentStatus
    extends StatelessWidget {
  final bool isPaid;

  const _PaymentStatus({
    required this.isPaid,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(
          isPaid
              ? Icons
                  .check_circle_outline
              : Icons.info_outline,
          size: 18,
          color: isPaid
              ? Colors.green
              : AppTheme
                  .textSecondaryColor,
        ),

        const SizedBox(
          width: 6,
        ),

        Text(
          isPaid
              ? 'Paid'
              : 'Not paid',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w500,
            color: isPaid
                ? Colors.green
                : AppTheme
                    .textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

class _DetailRow
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color:
              AppTheme.accentColor,
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip
    extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  Color _backgroundColor() {
    switch (
        status.toLowerCase()) {
      case 'confirmed':
        return Colors.green
            .withValues(
          alpha: 0.12,
        );

      case 'cancelled':
      case 'no show':
      case 'noshow':
        return Colors.red
            .withValues(
          alpha: 0.12,
        );

      case 'completed':
        return Colors.blueGrey
            .withValues(
          alpha: 0.12,
        );

      default:
        return AppTheme
            .accentColor
            .withValues(
          alpha: 0.12,
        );
    }
  }

  Color _foregroundColor() {
    switch (
        status.toLowerCase()) {
      case 'confirmed':
        return Colors
            .green.shade700;

      case 'cancelled':
      case 'no show':
      case 'noshow':
        return Colors
            .red.shade700;

      case 'completed':
        return Colors
            .blueGrey.shade700;

      default:
        return AppTheme
            .accentColor;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            _backgroundColor(),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        status,
        style:
            TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
          color:
              _foregroundColor(),
        ),
      ),
    );
  }
}