import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';

import '../client/appointments/reschedule_appointment_screen.dart';

class BarberAppointmentDetailsScreen
    extends StatefulWidget {
  final int appointmentId;

  const BarberAppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<BarberAppointmentDetailsScreen>
      createState() =>
          _BarberAppointmentDetailsScreenState();
}

class _BarberAppointmentDetailsScreenState
    extends State<BarberAppointmentDetailsScreen> {
  final AppointmentService _appointmentService =
      AppointmentService();

  Appointment? _appointment;

  bool _isLoading = true;
  bool _isUpdating = false;

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
          await _appointmentService
              .getAppointmentById(
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
        _errorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoading = false;
      });
    }
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await action();

      if (!mounted) return;

      await _loadAppointment();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successMessage,
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
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _confirmAppointment() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            size: 44,
          ),
          title: const Text(
            'Confirm appointment?',
          ),
          content: const Text(
            'This appointment will be marked as confirmed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Confirm',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _runAction(
      () => _appointmentService
          .confirmAppointment(
        widget.appointmentId,
      ),
      'Appointment confirmed successfully.',
    );
  }

  Future<void> _completeAppointment() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.task_alt_outlined,
            size: 44,
          ),
          title: const Text(
            'Complete appointment?',
          ),
          content: const Text(
            'This appointment will be marked as completed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Complete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _runAction(
      () => _appointmentService
          .completeAppointment(
        widget.appointmentId,
      ),
      'Appointment completed successfully.',
    );
  }

  Future<void> _markAsNoShow() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.person_off_outlined,
            size: 44,
          ),
          title: const Text(
            'Mark as no-show?',
          ),
          content: const Text(
            'The client will receive a no-show penalty for the next appointment.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Mark as no-show',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _runAction(
      () => _appointmentService
          .markAsNoShow(
        widget.appointmentId,
      ),
      'Appointment marked as no-show.',
    );
  }

  Future<void> _cancelAppointment() async {
    final appointment = _appointment;

    if (appointment == null) return;

    if (appointment.isPaid) {
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

    final reason =
        await showDialog<String>(
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
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Text(
                'Please enter a reason for cancelling this appointment.',
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                maxLength: 500,
                maxLines: 3,
                autofocus: true,
                onChanged: (value) {
                  cancellationReason =
                      value;
                },
                decoration:
                    const InputDecoration(
                  labelText:
                      'Cancellation reason',
                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Keep appointment',
              ),
            ),

            FilledButton(
              onPressed: () {
                final trimmed =
                    cancellationReason
                        .trim();

                if (trimmed.isEmpty) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(trimmed);
              },
              child: const Text(
                'Cancel appointment',
              ),
            ),
          ],
        );
      },
    );

    if (reason == null ||
        reason.isEmpty) {
      return;
    }

    await _runAction(
      () => _appointmentService
          .cancelAppointment(
        appointmentId:
            widget.appointmentId,
        cancellationReason:
            reason,
      ),
      'Appointment cancelled successfully.',
    );
  }

  Future<void> _rescheduleAppointment(
    Appointment appointment,
  ) async {
    final changed =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            RescheduleAppointmentScreen(
          appointment: appointment,
          showClientName: true,
        ),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await _loadAppointment();
    }
  }

  bool _canConfirm(
    Appointment appointment,
  ) {
    return appointment.status
                .toLowerCase() ==
            'pending' &&
        appointment.startDateTime
            .isAfter(DateTime.now());
  }

  bool _canNoShow(
    Appointment appointment,
  ) {
    return appointment.status
                .toLowerCase() ==
            'pending' &&
        !appointment.startDateTime
            .isAfter(DateTime.now());
  }

  bool _canComplete(
    Appointment appointment,
  ) {
    return appointment.status
                .toLowerCase() ==
            'confirmed' &&
        !appointment.endDateTime
            .isAfter(DateTime.now());
  }

  bool _canCancel(
    Appointment appointment,
  ) {
    final status =
        appointment.status
            .toLowerCase();

    return !appointment.isPaid &&
        appointment.startDateTime
            .isAfter(DateTime.now()) &&
        (status == 'pending' ||
            status == 'confirmed');
  }

  bool _canReschedule(
    Appointment appointment,
  ) {
    final status =
        appointment.status
            .toLowerCase();

    return appointment.startDateTime
            .isAfter(DateTime.now()) &&
        (status == 'pending' ||
            status == 'confirmed');
  }

  bool _hasActions(
    Appointment appointment,
  ) {
    return _canConfirm(
          appointment,
        ) ||
        _canNoShow(
          appointment,
        ) ||
        _canComplete(
          appointment,
        ) ||
        _canCancel(
          appointment,
        ) ||
        _canReschedule(
          appointment,
        );
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
                onPressed:
                    _loadAppointment,
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

    final appointment =
        _appointment;

    if (appointment == null) {
      return const Center(
        child: Text(
          'Appointment not found.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          _loadAppointment,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          20,
        ),
        children: [
          _buildHeader(
            appointment,
          ),

          const SizedBox(
            height: 18,
          ),

          _buildDetailsCard(
            appointment,
          ),

          const SizedBox(
            height: 18,
          ),

          _buildPriceCard(
            appointment,
          ),

          if (appointment
                  .cancellationReason
                  ?.isNotEmpty ==
              true) ...[
            const SizedBox(
              height: 18,
            ),

            _buildCancellationCard(
              appointment,
            ),
          ],

          if (_hasActions(
            appointment,
          )) ...[
            const SizedBox(
              height: 24,
            ),

            _buildActions(
              appointment,
            ),
          ],

          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    Appointment appointment,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  AppTheme.accentColor
                      .withValues(
                alpha: 0.12,
              ),
              child: const Icon(
                Icons.person_outline,
                color:
                    AppTheme.accentColor,
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
                  Text(
                    appointment
                        .clientFullName,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    appointment
                        .serviceName,
                    style:
                        const TextStyle(
                      color:
                          AppTheme
                              .textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            _StatusChip(
              status:
                  appointment.status,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    Appointment appointment,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Column(
          children: [
            _DetailRow(
              icon:
                  Icons
                      .calendar_today_outlined,
              label: 'Start',
              value:
                  _formatDateTime(
                appointment
                    .startDateTime,
              ),
            ),

            const Divider(
              height: 28,
            ),

            _DetailRow(
              icon:
                  Icons.schedule_outlined,
              label: 'End',
              value:
                  _formatDateTime(
                appointment
                    .endDateTime,
              ),
            ),

            const Divider(
              height: 28,
            ),

            _DetailRow(
              icon:
                  Icons.timer_outlined,
              label: 'Duration',
              value:
                  '${appointment.durationMinutes} min',
            ),

            const Divider(
              height: 28,
            ),

            _DetailRow(
              icon:
                  Icons
                      .payments_outlined,
              label: 'Payment',
              value:
                  appointment.isPaid
                      ? 'Paid'
                      : 'Not paid',
            ),

            const Divider(
              height: 28,
            ),

            _DetailRow(
              icon:
                  Icons
                      .notifications_outlined,
              label: 'Reminder',
              value:
                  appointment
                          .reminderEnabled
                      ? 'Enabled'
                      : 'Disabled',
            ),

            if (appointment
                .hasReview) ...[
              const Divider(
                height: 28,
              ),

              const _DetailRow(
                icon:
                    Icons.star_outline,
                label: 'Review',
                value:
                    'Reviewed',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(
    Appointment appointment,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Column(
          children: [
            _PriceRow(
              label:
                  'Base price',
              value:
                  '${appointment.basePrice.toStringAsFixed(2)} BAM',
            ),

            if (appointment
                    .appliedDiscountPercent >
                0) ...[
              const SizedBox(
                height: 10,
              ),

              _PriceRow(
                label:
                    'Discount',
                value:
                    '-${appointment.appliedDiscountPercent.toStringAsFixed(0)}%',
              ),
            ],

            if (appointment
                    .appliedPenaltyPercent >
                0) ...[
              const SizedBox(
                height: 10,
              ),

              _PriceRow(
                label:
                    'No-show penalty',
                value:
                    '+${appointment.appliedPenaltyPercent.toStringAsFixed(0)}%',
              ),
            ],

            const Divider(
              height: 26,
            ),

            _PriceRow(
              label:
                  'Final price',
              value:
                  '${appointment.finalPrice.toStringAsFixed(2)} BAM',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationCard(
    Appointment appointment,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              color:
                  AppTheme.accentColor,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'Cancellation reason',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    appointment
                            .cancellationReason ??
                        '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(
    Appointment appointment,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        if (_canConfirm(
          appointment,
        ))
          SizedBox(
            width:
                double.infinity,
            child:
                FilledButton.icon(
              onPressed:
                  _isUpdating
                      ? null
                      : _confirmAppointment,
              icon:
                  const Icon(
                Icons
                    .check_circle_outline,
              ),
              label:
                  const Text(
                'Confirm appointment',
              ),
            ),
          ),

        if (_canComplete(
          appointment,
        ))
          SizedBox(
            width:
                double.infinity,
            child:
                FilledButton.icon(
              onPressed:
                  _isUpdating
                      ? null
                      : _completeAppointment,
              icon:
                  const Icon(
                Icons
                    .task_alt_outlined,
              ),
              label:
                  const Text(
                'Complete appointment',
              ),
            ),
          ),

        if (_canNoShow(
          appointment,
        ))
          SizedBox(
            width:
                double.infinity,
            child:
                FilledButton.icon(
              onPressed:
                  _isUpdating
                      ? null
                      : _markAsNoShow,
              icon:
                  const Icon(
                Icons
                    .person_off_outlined,
              ),
              label:
                  const Text(
                'Mark as no-show',
              ),
            ),
          ),

        if (_canReschedule(
          appointment,
        )) ...[
          const SizedBox(
            height: 10,
          ),

          SizedBox(
            width:
                double.infinity,
            child:
                OutlinedButton.icon(
              onPressed:
                  _isUpdating
                      ? null
                      : () {
                          _rescheduleAppointment(
                            appointment,
                          );
                        },
              icon:
                  const Icon(
                Icons
                    .edit_calendar_outlined,
              ),
              label:
                  const Text(
                'Reschedule',
              ),
            ),
          ),
        ],

        if (_canCancel(
          appointment,
        )) ...[
          const SizedBox(
            height: 10,
          ),

          SizedBox(
            width:
                double.infinity,
            child:
                OutlinedButton.icon(
              onPressed:
                  _isUpdating
                      ? null
                      : _cancelAppointment,
              icon:
                  const Icon(
                Icons.close,
              ),
              label:
                  const Text(
                'Cancel appointment',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
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
          width: 12,
        ),

        Expanded(
          child: Text(
            label,
            style:
                const TextStyle(
              color:
                  AppTheme
                      .textSecondaryColor,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow
    extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                TextStyle(
              fontWeight:
                  bold
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ),

        Text(
          value,
          style:
              TextStyle(
            fontWeight:
                bold
                    ? FontWeight.bold
                    : FontWeight.w500,
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
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.withValues(
          alpha: 0.12,
        );

      case 'cancelled':
      case 'no show':
      case 'noshow':
        return Colors.red.withValues(
          alpha: 0.12,
        );

      case 'completed':
        return Colors.blueGrey.withValues(
          alpha: 0.12,
        );

      default:
        return AppTheme.accentColor
            .withValues(
          alpha: 0.12,
        );
    }
  }

  Color _foregroundColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade700;

      case 'cancelled':
      case 'no show':
      case 'noshow':
        return Colors.red.shade700;

      case 'completed':
        return Colors.blueGrey.shade700;

      default:
        return AppTheme.accentColor;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
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
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
          color:
              _foregroundColor(),
        ),
      ),
    );
  }
}