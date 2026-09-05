import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState
    extends State<AppointmentDetailsScreen> {
  final AppointmentService _appointmentService =
      AppointmentService();

  Appointment? _appointment;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointment =
          await _appointmentService.getAppointmentById(
        widget.appointmentId,
      );

      if (!mounted) return;

      setState(() {
        _appointment = appointment;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e
            .toString()
            .replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month =
        value.month.toString().padLeft(2, '0');

    return '$day.$month.${value.year}.';
  }

  String _formatTime(DateTime value) {
    final hour =
        value.hour.toString().padLeft(2, '0');
    final minute =
        value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointment details',
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
                onPressed: _loadAppointment,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final appointment = _appointment;

    if (appointment == null) {
      return const Center(
        child: Text(
          'Appointment not found.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointment,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(appointment),

          const SizedBox(height: 16),

          _buildAppointmentCard(appointment),

          const SizedBox(height: 16),

          _buildPaymentCard(appointment),

          if (appointment.status.toLowerCase() ==
                  'cancelled' &&
              appointment.cancellationReason !=
                  null &&
              appointment.cancellationReason!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCancellationCard(
              appointment.cancellationReason!,
            ),
          ],

          if (appointment.status.toLowerCase() ==
              'completed') ...[
            const SizedBox(height: 16),
            _buildReviewCard(appointment),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(
    Appointment appointment,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.accentColor
                    .withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.content_cut,
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
                    appointment.serviceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    appointment.status,
                    style: const TextStyle(
                      color:
                          AppTheme.accentColor,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    Appointment appointment,
  ) {
    return _SectionCard(
      title: 'Appointment',
      children: [
        _DetailRow(
          icon: Icons.person_outline,
          label: 'Barber',
          value: appointment.barberFullName,
        ),
        _DetailRow(
          icon: Icons.calendar_today_outlined,
          label: 'Date',
          value: _formatDate(
            appointment.startDateTime,
          ),
        ),
        _DetailRow(
          icon: Icons.schedule_outlined,
          label: 'Time',
          value:
              '${_formatTime(appointment.startDateTime)} - '
              '${_formatTime(appointment.endDateTime)}',
        ),
        _DetailRow(
          icon: Icons.timelapse_outlined,
          label: 'Duration',
          value:
              '${appointment.durationMinutes} min',
        ),
        _DetailRow(
          icon:
              Icons.notifications_outlined,
          label: 'Reminder',
          value:
              appointment.reminderEnabled
                  ? 'Enabled'
                  : 'Disabled',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
    Appointment appointment,
  ) {
    final hasDiscount =
        appointment.appliedDiscountPercent > 0;

    final hasPenalty =
        appointment.appliedPenaltyPercent > 0;

    return _SectionCard(
      title: 'Payment',
      children: [
        _DetailRow(
          icon: Icons.payments_outlined,
          label: 'Base price',
          value:
              '${appointment.basePrice.toStringAsFixed(2)} BAM',
        ),

        if (hasDiscount)
          _DetailRow(
            icon: Icons.discount_outlined,
            label: 'Discount',
            value:
                '${appointment.appliedDiscountPercent.toStringAsFixed(0)}%',
          ),

        if (hasPenalty)
          _DetailRow(
            icon: Icons.trending_up,
            label: 'Price adjustment',
            value:
                '${appointment.appliedPenaltyPercent.toStringAsFixed(0)}%',
          ),

        _DetailRow(
          icon: Icons.receipt_long_outlined,
          label: 'Final price',
          value:
              '${appointment.finalPrice.toStringAsFixed(2)} BAM',
        ),

        _DetailRow(
          icon: appointment.isPaid
              ? Icons.check_circle_outline
              : Icons.info_outline,
          label: 'Payment status',
          value:
              appointment.isPaid
                  ? 'Paid'
                  : 'Not paid',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildCancellationCard(
    String reason,
  ) {
    return _SectionCard(
      title: 'Cancellation',
      children: [
        _DetailRow(
          icon: Icons.cancel_outlined,
          label: 'Reason',
          value: reason,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    Appointment appointment,
  ) {
    return _SectionCard(
      title: 'Review',
      children: [
        _DetailRow(
          icon: appointment.hasReview
              ? Icons.star_outline
              : Icons.rate_review_outlined,
          label: 'Status',
          value: appointment.hasReview
              ? 'Reviewed'
              : 'Not reviewed',
          isLast: true,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.accentColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme
                          .textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}