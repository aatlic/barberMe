import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import 'barber_appointment_details_screen.dart';

class BarberAppointmentsScreen extends StatefulWidget {
  const BarberAppointmentsScreen({
    super.key,
  });

  @override
  State<BarberAppointmentsScreen> createState() =>
      _BarberAppointmentsScreenState();
}

class _BarberAppointmentsScreenState
    extends State<BarberAppointmentsScreen> {
  final AppointmentService _appointmentService =
      AppointmentService();

  List<Appointment> _appointments = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedListType = 'Upcoming';

  @override
  void initState() {
    super.initState();

    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _appointmentService.getAppointments(
        listType: _selectedListType,
        page: 1,
        pageSize: 50,
      );

      if (!mounted) return;

      setState(() {
        _appointments = result.items;
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

  Future<void> _changeListType(
    String listType,
  ) async {
    if (_selectedListType == listType) {
      return;
    }

    setState(() {
      _selectedListType = listType;
    });

    await _loadAppointments();
  }

  String _formatDate(
    DateTime value,
  ) {
    final day =
        value.day.toString().padLeft(2, '0');

    final month =
        value.month.toString().padLeft(2, '0');

    return '$day.$month.${value.year}.';
  }

  String _formatTime(
    DateTime value,
  ) {
    final hour =
        value.hour.toString().padLeft(2, '0');

    final minute =
        value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterButton(
                      text: 'Upcoming',
                      selected:
                          _selectedListType ==
                              'Upcoming',
                      onPressed: () {
                        _changeListType(
                          'Upcoming',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterButton(
                      text: 'History',
                      selected:
                          _selectedListType ==
                              'History',
                      onPressed: () {
                        _changeListType(
                          'History',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
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
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadAppointments,
                child: const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAppointments,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                      0.5,
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons
                            .calendar_month_outlined,
                        size: 58,
                        color: AppTheme
                            .textSecondaryColor,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Text(
                        _selectedListType ==
                                'Upcoming'
                            ? 'No upcoming appointments.'
                            : 'No appointment history.',
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24,
        ),
        itemCount: _appointments.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (
          context,
          index,
        ) {
          final appointment =
              _appointments[index];

          return _AppointmentCard(
            appointment: appointment,
            formattedDate: _formatDate(
              appointment.startDateTime,
            ),
            formattedStartTime: _formatTime(
              appointment.startDateTime,
            ),
            formattedEndTime: _formatTime(
              appointment.endDateTime,
            ),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      BarberAppointmentDetailsScreen(
                    appointmentId:
                        appointment.id,
                  ),
                ),
              );

              if (!mounted) return;

              await _loadAppointments();
            },
          );
        },
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onPressed;

  const _FilterButton({
    required this.text,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (selected) {
      return FilledButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  final String formattedDate;
  final String formattedStartTime;
  final String formattedEndTime;

  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.formattedDate,
    required this.formattedStartTime,
    required this.formattedEndTime,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
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
                  const SizedBox(width: 14),
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
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          appointment
                              .serviceName,
                          style:
                              const TextStyle(
                            color: AppTheme
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 18,
                    color:
                        AppTheme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 18,
                    color:
                        AppTheme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$formattedStartTime - '
                    '$formattedEndTime',
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(
                    Icons
                        .payments_outlined,
                    size: 18,
                    color:
                        AppTheme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.finalPrice.toStringAsFixed(2)} BAM',
                  ),
                  const Spacer(),
                  Text(
                    appointment.isPaid
                        ? 'Paid'
                        : 'Not paid',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          appointment.isPaid
                              ? Colors.green
                              : AppTheme
                                  .textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment:
                    Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  color: AppTheme
                      .textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
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
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _foregroundColor(),
        ),
      ),
    );
  }
}