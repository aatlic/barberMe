import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:table_calendar/table_calendar.dart';

import '../../../../models/available_slot.dart';
import '../../../../models/calendar_availability.dart';
import '../../../../services/appointment_service.dart';
import '../../../../services/payment_service.dart';
import '../client_main_screen.dart';
import '../../../../services/recommendation_service.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final int barberId;
  final int barberServiceId;
  final int serviceId;

  final String barberName;
  final String serviceName;

  final double price;
  final int durationMinutes;

  final int? recommendationId;

  const SelectDateTimeScreen({
    super.key,
    required this.barberId,
    required this.barberServiceId,
    required this.serviceId,
    required this.barberName,
    required this.serviceName,
    required this.price,
    required this.durationMinutes,
    this.recommendationId,
  });

  @override
  State<SelectDateTimeScreen> createState() =>
      _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState
    extends State<SelectDateTimeScreen> {
  final AppointmentService _appointmentService =
      AppointmentService();

  final PaymentService _paymentService =
      PaymentService();
  
  final RecommendationService _recommendationService =
      RecommendationService();

  bool _isBooking = false;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  AvailableSlot? _selectedSlot;

  List<AvailableSlot> _availableSlots = [];
  List<CalendarAvailability> _calendarAvailability = [];

  bool _isLoadingSlots = false;
  bool _isLoadingCalendar = true;

  String? _errorMessage;
  String? _calendarErrorMessage;

  @override
  void initState() {
    super.initState();

    _focusedDay = DateTime.now();

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
        barberId: widget.barberId,
        serviceId: widget.serviceId,
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
    for (final item
        in _calendarAvailability) {
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

    if (normalizedDay.isBefore(
      today,
    )) {
      return false;
    }

    final availability =
        _getAvailability(day);

    return availability?.isWorkingDay ==
        true;
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedDate == null) {
      return;
    }

    setState(() {
      _isLoadingSlots = true;
      _errorMessage = null;
      _selectedSlot = null;
    });

    try {
      final slots =
          await _appointmentService.getAvailableSlots(
        barberId: widget.barberId,
        serviceId: widget.serviceId,
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
        _errorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _payAppointment(
    int appointmentId,
  ) async {
    final payment =
        await _paymentService.createPayment(
      appointmentId,
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

    await Stripe.instance
        .presentPaymentSheet();

    await _paymentService.confirmPayment(
      payment.id,
    );
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null ||
        _isBooking) {
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final appointment =
          await _appointmentService
              .createAppointment(
        barberServiceId:
            widget.barberServiceId,
        startDateTime:
            _selectedSlot!.startDateTime,
        reminderEnabled: false,
      );

      if (widget.recommendationId != null) {
        await _recommendationService.setAcceptance(
          recommendationId:
              widget.recommendationId!,
          wasAccepted: true,
        );
      }
      
      if (!mounted) return;

      final enableReminder =
          await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 44,
            ),
            title: const Text(
              'Set a reminder?',
            ),
            content: const Text(
              'Would you like to receive a reminder before your appointment?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(false);
                },
                child: const Text(
                  'Not now',
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(true);
                },
                child: const Text(
                  'Set reminder',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (enableReminder == true) {
        await _appointmentService
            .updateReminder(
          appointmentId:
              appointment.id,
          reminderEnabled: true,
        );
      }

      if (!mounted) return;

      final payNow =
          await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.payments_outlined,
              size: 44,
            ),
            title: const Text(
              'Pay now?',
            ),
            content: Text(
              'Would you like to pay '
              '${widget.price.toStringAsFixed(2)} BAM '
              'now?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(false);
                },
                child: const Text(
                  'Pay later',
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(true);
                },
                child: const Text(
                  'Pay now',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (payNow == true) {
        try {
          await _payAppointment(
            appointment.id,
          );

          if (!mounted) return;

          await showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                icon: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                ),
                title: const Text(
                  'Payment successful',
                ),
                content: const Text(
                  'Your appointment has been paid successfully.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(
                        dialogContext,
                      ).pop();
                    },
                    child:
                        const Text('OK'),
                  ),
                ],
              );
            },
          );
        } on StripeException catch (e) {
          if (!mounted) return;

          if (e.error.code ==
              FailureCode.Canceled) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  'Payment was cancelled.',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  e.error.localizedMessage ??
                      'Payment failed.',
                ),
              ),
            );
          }
        }
      }

      if (!mounted) return;

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              ClientMainScreen(
            initialIndex: 1,
            recommendationIdToRate:
                widget.recommendationId,
          ),
        ),
        (route) => false,
      );
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
          _isBooking = false;
        });
      }
    }
  }

  String _formatTime(
    DateTime dateTime,
  ) {
    final hour =
        dateTime.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final minute =
        dateTime.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$hour:$minute';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select date & time',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
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
                  _buildBookingSummary(),

                  const SizedBox(
                    height: 24,
                  ),

                  Text(
                    'Select date',
                    style:
                        Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight
                                      .bold,
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

                  if (_selectedDate !=
                      null) ...[
                    const SizedBox(
                      height: 28,
                    ),

                    Text(
                      'Available times',
                      style:
                          Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .bold,
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

    if (_calendarErrorMessage !=
        null) {
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
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();

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
          focusedDay: _focusedDay,

          calendarFormat:
              CalendarFormat.month,

          availableCalendarFormats:
              const {
            CalendarFormat.month:
                'Month',
          },

          headerStyle:
              const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
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

              _selectedSlot = null;
              _availableSlots = [];

              _errorMessage = null;
            });

            await _loadAvailableSlots();
          },

          onPageChanged:
              (focusedDay) {
            setState(() {
              _focusedDay =
                  focusedDay;

              _selectedDate = null;
              _selectedSlot = null;

              _availableSlots = [];
              _errorMessage = null;
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
                  _getAvailability(day);

              if (availability == null ||
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

  Widget _buildBookingSummary() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 20,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    widget.barberName,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                const Icon(
                  Icons.content_cut,
                  size: 20,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    widget.serviceName,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
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
                  '${widget.durationMinutes} min',
                ),

                const Spacer(),

                Text(
                  '${widget.price.toStringAsFixed(2)} BAM',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
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

    if (_errorMessage != null) {
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
              _errorMessage!,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton(
              onPressed:
                  _loadAvailableSlots,
              child: const Text(
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
            selected: isSelected,
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
                    _isBooking
                ? null
                : _bookAppointment,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),
          child: _isBooking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Book appointment',
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