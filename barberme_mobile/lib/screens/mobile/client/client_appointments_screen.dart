import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

import '../../../core/theme/app_theme.dart';
import '../../../models/appointment.dart';
import '../../../services/appointment_service.dart';
import '../../../services/payment_service.dart';

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

  List<Appointment> _appointments = [];

  bool _isLoading = true;
  String? _errorMessage;

  int? _payingAppointmentId;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final result =
          await _appointmentService.getAppointments();

      if (!mounted) return;

      setState(() {
        _appointments = result.items;
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

  Future<void> _payAppointment(
    Appointment appointment,
  ) async {
    if (_payingAppointmentId != null) {
      return;
    }

    setState(() {
      _payingAppointmentId = appointment.id;
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
          merchantDisplayName: 'Barber Me',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await _paymentService.confirmPayment(
        payment.id,
      );

      if (!mounted) return;

      await _loadAppointments();

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

      if (e.error.code == FailureCode.Canceled) {
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

  bool _canPay(Appointment appointment) {
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

    if (appointment.startDateTime
        .isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  String _formatDateTime(DateTime value) {
    final day =
        value.day.toString().padLeft(2, '0');
    final month =
        value.month.toString().padLeft(2, '0');
    final year = value.year;

    final hour =
        value.hour.toString().padLeft(2, '0');
    final minute =
        value.minute.toString().padLeft(2, '0');

    return '$day.$month.$year. $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
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
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  _loadAppointments();
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

    if (_appointments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 56,
                color:
                    AppTheme.textSecondaryColor,
              ),
              SizedBox(height: 16),
              Text(
                'No appointments yet.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your appointments will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _appointments.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final appointment =
              _appointments[index];

          return _AppointmentCard(
            appointment: appointment,
            formattedDate: _formatDateTime(
              appointment.startDateTime,
            ),
            canPay: _canPay(appointment),
            isPaying:
                _payingAppointmentId ==
                    appointment.id,
            onPay: () {
              _payAppointment(appointment);
            },
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String formattedDate;
  final bool canPay;
  final bool isPaying;
  final VoidCallback onPay;

  const _AppointmentCard({
    required this.appointment,
    required this.formattedDate,
    required this.canPay,
    required this.isPaying,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(
                  status: appointment.status,
                ),
              ],
            ),

            const SizedBox(height: 14),

            _DetailRow(
              icon: Icons.person_outline,
              text:
                  appointment.barberFullName,
            ),

            const SizedBox(height: 8),

            _DetailRow(
              icon: Icons.schedule_outlined,
              text: formattedDate,
            ),

            const SizedBox(height: 8),

            _DetailRow(
              icon: Icons.payments_outlined,
              text:
                  '${appointment.finalPrice.toStringAsFixed(2)} BAM',
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Icon(
                  appointment.isPaid
                      ? Icons
                          .check_circle_outline
                      : Icons.info_outline,
                  size: 18,
                  color: appointment.isPaid
                      ? Colors.green
                      : AppTheme
                          .textSecondaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  appointment.isPaid
                      ? 'Paid'
                      : 'Not paid',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w500,
                    color: appointment.isPaid
                        ? Colors.green
                        : AppTheme
                            .textSecondaryColor,
                  ),
                ),
              ],
            ),

            if (canPay) ...[
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      isPaying ? null : onPay,
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
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.accentColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentColor
            .withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.accentColor,
        ),
      ),
    );
  }
}