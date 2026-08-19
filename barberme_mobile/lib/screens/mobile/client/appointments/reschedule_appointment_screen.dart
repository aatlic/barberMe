import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../models/appointment.dart';
import '../../../../models/available_slot.dart';
import '../../../../models/calendar_availability.dart';
import '../../../../services/appointment_service.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const RescheduleAppointmentScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  final AppointmentService _appointmentService =
      AppointmentService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  AvailableSlot? _selectedSlot;

  List<AvailableSlot> _availableSlots = [];
  List<CalendarAvailability> _calendarAvailability = [];

  bool _isLoadingCalendar = true;
  bool _isLoadingSlots = false;
  bool _isSaving = false;

  String? _calendarErrorMessage;
  String? _slotsErrorMessage;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _focusedDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    _loadCalendarAvailability(
      _focusedDay,
    );
  }

  Future<void> _loadCalendarAvailability(
    DateTime focusedDay,
  ) async {
    setState(() {
      _isLoadingCalendar = true;
      _calendarErrorMessage = null;
    });

    try {
      final result =
          await _appointmentService.getCalendarAvailability(
        barberId: widget.appointment.barberId,
        serviceId: widget.appointment.serviceId,
        year: focusedDay.year,
        month: focusedDay.month,
      );

      if (!mounted) return;

      setState(() {
        _calendarAvailability = result;
        _isLoadingCalendar = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _calendarErrorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoadingCalendar = false;
      });
    }
  }

  CalendarAvailability? _getAvailability(
    DateTime day,
  ) {
    for (final item in _calendarAvailability) {
      if (isSameDay(
        item.date,
        day,
      )) {
        return item;
      }
    }

    return null;
  }

  bool _isDaySelectable(
    DateTime day,
  ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final normalizedDay = DateTime(
      day.year,
      day.month,
      day.day,
    );

    if (normalizedDay.isBefore(today)) {
      return false;
    }

    final availability =
        _getAvailability(day);

    return availability?.isWorkingDay == true;
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedDate == null) {
      return;
    }

    setState(() {
      _isLoadingSlots = true;
      _slotsErrorMessage = null;
      _selectedSlot = null;
      _availableSlots = [];
    });

    try {
      final slots =
          await _appointmentService.getAvailableSlots(
        barberId: widget.appointment.barberId,
        serviceId: widget.appointment.serviceId,
        date: _selectedDate!,
      );

      if (!mounted) return;

      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _slotsErrorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _saveNewTime() async {
    if (_selectedSlot == null ||
        _isSaving) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.edit_calendar_outlined,
            size: 44,
          ),
          title: const Text(
            'Reschedule appointment?',
          ),
          content: Text(
            'Change your appointment to '
            '${_formatDateTime(_selectedSlot!.startDateTime)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Keep current time',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Reschedule',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _appointmentService
          .rescheduleAppointment(
        appointmentId:
            widget.appointment.id,
        startDateTime:
            _selectedSlot!.startDateTime,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline,
              size: 48,
            ),
            title: const Text(
              'Appointment rescheduled',
            ),
            content: const Text(
              'Your appointment time has been updated successfully.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
          _isSaving = false;
        });
      }
    }
  }

  String _formatTime(
    DateTime value,
  ) {
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

    return '$hour:$minute';
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

    return '$day.$month.${value.year}. '
        '${_formatTime(value)}';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reschedule appointment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                children: [
                  _buildCurrentAppointment(),

                  const SizedBox(
                    height: 24,
                  ),

                  Text(
                    'Select new date',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildCalendar(),

                  const SizedBox(
                    height: 12,
                  ),

                  const _CalendarLegend(),

                  if (_selectedDate != null) ...[
                    const SizedBox(
                      height: 28,
                    ),

                    Text(
                      'Available times',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _buildSlots(),
                  ],
                ],
              ),
            ),

            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAppointment() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Current appointment',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w600,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              widget.appointment
                  .serviceName,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 20,
                ),

                const SizedBox(
                  width: 10,
                ),

                Text(
                  widget.appointment
                      .barberFullName,
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  size: 20,
                ),

                const SizedBox(
                  width: 10,
                ),

                Text(
                  _formatDateTime(
                    widget.appointment
                        .startDateTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    if (_isLoadingCalendar) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 40,
        ),
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_calendarErrorMessage != null) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 42,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              _calendarErrorMessage!,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton(
              onPressed: () {
                _loadCalendarAvailability(
                  _focusedDay,
                );
              },
              child:
                  const Text(
                'Try again',
              ),
            ),
          ],
        ),
      );
    }

    final now =
        DateTime.now();

    final firstDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final lastDay = DateTime(
      now.year + 1,
      now.month,
      now.day,
    );

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          8,
        ),
        child: TableCalendar(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay:
              _focusedDay,

          calendarFormat:
              CalendarFormat.month,

          availableCalendarFormats:
              const {
            CalendarFormat.month:
                'Month',
          },

          headerStyle:
              const HeaderStyle(
            formatButtonVisible:
                false,
            titleCentered:
                true,
          ),

          selectedDayPredicate:
              (day) {
            return _selectedDate !=
                    null &&
                isSameDay(
                  _selectedDate,
                  day,
                );
          },

          enabledDayPredicate:
              (day) {
            return _isDaySelectable(
              day,
            );
          },

          onDaySelected: (
            selectedDay,
            focusedDay,
          ) async {
            if (!_isDaySelectable(
              selectedDay,
            )) {
              return;
            }

            setState(() {
              _selectedDate =
                  selectedDay;

              _focusedDay =
                  focusedDay;

              _selectedSlot =
                  null;

              _availableSlots =
                  [];

              _slotsErrorMessage =
                  null;
            });

            await _loadAvailableSlots();
          },

          onPageChanged:
              (focusedDay) {
            setState(() {
              _focusedDay =
                  focusedDay;

              _selectedDate =
                  null;

              _selectedSlot =
                  null;

              _availableSlots =
                  [];

              _slotsErrorMessage =
                  null;
            });

            _loadCalendarAvailability(
              focusedDay,
            );
          },

          calendarBuilders:
              CalendarBuilders(
            markerBuilder: (
              context,
              day,
              events,
            ) {
              final availability =
                  _getAvailability(
                day,
              );

              if (availability ==
                      null ||
                  !availability
                      .isWorkingDay) {
                return null;
              }

              final markerColor =
                  availability
                          .hasAvailableSlots
                      ? Colors.green
                      : Colors.red;

              return Positioned(
                bottom: 5,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(
                    color:
                        markerColor,
                    shape:
                        BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSlots() {
    if (_isLoadingSlots) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 30,
        ),
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_slotsErrorMessage != null) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 42,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              _slotsErrorMessage!,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton(
              onPressed:
                  _loadAvailableSlots,
              child:
                  const Text(
                'Try again',
              ),
            ),
          ],
        ),
      );
    }

    if (_availableSlots.isEmpty) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 24,
        ),
        child: Center(
          child: Text(
            'No available appointments for this date.',
            textAlign:
                TextAlign.center,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _availableSlots.map(
        (slot) {
          final isSelected =
              _selectedSlot
                      ?.startDateTime ==
                  slot.startDateTime;

          return ChoiceChip(
            label: Text(
              _formatTime(
                slot.startDateTime,
              ),
            ),
            selected:
                isSelected,
            onSelected: (_) {
              setState(() {
                _selectedSlot =
                    slot;
              });
            },
          );
        },
      ).toList(),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20,
      ),
      child: FilledButton(
        onPressed:
            _selectedSlot == null ||
                    _isSaving
                ? null
                : _saveNewTime,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth:
                        2,
                  ),
                )
              : const Text(
                  'Save new time',
                ),
        ),
      ),
    );
  }
}

class _CalendarLegend
    extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: Colors.green,
          text: 'Available',
        ),

        SizedBox(
          width: 22,
        ),

        _LegendItem(
          color: Colors.red,
          text: 'Fully booked',
        ),
      ],
    );
  }
}

class _LegendItem
    extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),

        const SizedBox(
          width: 6,
        ),

        Text(
          text,
          style:
              const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}