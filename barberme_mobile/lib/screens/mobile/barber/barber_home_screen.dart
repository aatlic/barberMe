import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/appointment.dart';
import '../../../models/user.dart';
import '../../../services/appointment_service.dart';
import '../../../services/user_service.dart';
import 'booking/barber_select_service_screen.dart';

class BarberHomeScreen extends StatefulWidget {
  const BarberHomeScreen({
    super.key,
  });

  @override
  State<BarberHomeScreen> createState() =>
      _BarberHomeScreenState();
}

class _BarberHomeScreenState
    extends State<BarberHomeScreen> {
  final UserService _userService =
      UserService();

  final AppointmentService _appointmentService =
      AppointmentService();

  final TextEditingController _searchController =
      TextEditingController();

  List<User> _clients = [];

  User? _selectedClient;

  List<Appointment> _clientAppointments = [];

  bool _isSearching = false;
  bool _isLoadingAppointments = false;

  String? _searchErrorMessage;
  String? _appointmentsErrorMessage;

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _searchClients() async {
    final search =
        _searchController.text.trim();

    if (search.isEmpty) {
      setState(() {
        _clients = [];
        _selectedClient = null;
        _clientAppointments = [];
        _searchErrorMessage = null;
      });

      return;
    }

    setState(() {
      _isSearching = true;
      _searchErrorMessage = null;

      _selectedClient = null;
      _clientAppointments = [];
    });

    try {
      final result =
          await _userService.getClients(
        fts: search,
        page: 1,
        pageSize: 20,
      );

      if (!mounted) return;

      setState(() {
        _clients = result.items;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchErrorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isSearching = false;
      });
    }
  }

  Future<void> _selectClient(
    User client,
  ) async {
    setState(() {
      _selectedClient = client;
      _clientAppointments = [];

      _isLoadingAppointments = true;
      _appointmentsErrorMessage = null;
    });

    try {
      final result =
          await _appointmentService
              .getAppointments(
        clientId: client.id,
        page: 1,
        pageSize: 20,
      );

      if (!mounted) return;

      setState(() {
        _clientAppointments =
            result.items;

        _isLoadingAppointments = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _appointmentsErrorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoadingAppointments = false;
      });
    }
  }

  Future<void> _refreshSelectedClient() async {
    final client = _selectedClient;

    if (client == null) {
      return;
    }

    await _selectClient(client);
  }

  void _clearSelectedClient() {
    setState(() {
      _selectedClient = null;
      _clientAppointments = [];
      _appointmentsErrorMessage = null;
    });
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
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(
            20,
          ),
          children: [
            const Text(
              'Find client',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Search for a client by first or last name.',
              style: TextStyle(
                color:
                    AppTheme.textSecondaryColor,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  _searchController,
              textInputAction:
                  TextInputAction.search,
              decoration:
                  InputDecoration(
                hintText:
                    'Search clients',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    _searchController
                            .text
                            .isNotEmpty
                        ? IconButton(
                            tooltip:
                                'Clear search',
                            onPressed: () {
                              _searchController
                                  .clear();

                              setState(() {
                                _clients = [];
                                _selectedClient =
                                    null;
                                _clientAppointments =
                                    [];
                              });
                            },
                            icon:
                                const Icon(
                              Icons.close,
                            ),
                          )
                        : null,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
              onSubmitted: (_) {
                _searchClients();
              },
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed:
                    _isSearching
                        ? null
                        : _searchClients,
                icon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.search,
                      ),
                label: Text(
                  _isSearching
                      ? 'Searching...'
                      : 'Search',
                ),
              ),
            ),

            if (_searchErrorMessage !=
                null) ...[
              const SizedBox(
                height: 16,
              ),

              Text(
                _searchErrorMessage!,
                style:
                    const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],

            if (_clients.isNotEmpty &&
                _selectedClient ==
                    null) ...[
              const SizedBox(
                height: 24,
              ),

              const Text(
                'Clients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              ..._clients.map(
                (client) =>
                    _ClientCard(
                  client: client,
                  onTap: () {
                    _selectClient(
                      client,
                    );
                  },
                ),
              ),
            ],

            if (!_isSearching &&
                _searchController
                    .text
                    .trim()
                    .isNotEmpty &&
                _clients.isEmpty &&
                _searchErrorMessage ==
                    null &&
                _selectedClient ==
                    null) ...[
              const SizedBox(
                height: 28,
              ),

              const Icon(
                Icons.person_search_outlined,
                size: 52,
                color:
                    AppTheme
                        .textSecondaryColor,
              ),

              const SizedBox(
                height: 12,
              ),

              const Text(
                'No clients found.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],

            if (_selectedClient !=
                null) ...[
              const SizedBox(
                height: 28,
              ),

              _buildSelectedClient(
                _selectedClient!,
              ),

              const SizedBox(
                height: 20,
              ),

              _buildClientAppointments(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedClient(
    User client,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      AppTheme
                          .accentColor
                          .withValues(
                    alpha: 0.12,
                  ),
                  child: Text(
                    _getInitials(
                      client,
                    ),
                    style:
                        const TextStyle(
                      color:
                          AppTheme
                              .accentColor,
                      fontWeight:
                          FontWeight.bold,
                    ),
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
                        '${client.firstName} ${client.lastName}',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        client.email,
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

                IconButton(
                  tooltip:
                      'Change client',
                  onPressed:
                      _clearSelectedClient,
                  icon:
                      const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  FilledButton.icon(
                onPressed: () async {
                  final barber =
                      await _userService.getCurrentUser();

                  if (!mounted) return;

                  final created =
                      await Navigator.of(context)
                          .push<bool>(
                    MaterialPageRoute(
                      builder: (_) =>
                          BarberSelectServiceScreen(
                        client: client,
                        barber: barber,
                      ),
                    ),
                  );

                  if (created == true) {
                    await _refreshSelectedClient();
                  }
                },
                icon:
                    const Icon(
                  Icons
                      .add_circle_outline,
                ),
                label:
                    const Text(
                  'Create appointment',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientAppointments() {
    if (_isLoadingAppointments) {
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

    if (_appointmentsErrorMessage !=
        null) {
      return Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 42,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            _appointmentsErrorMessage!,
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
            height: 12,
          ),

          OutlinedButton(
            onPressed:
                _refreshSelectedClient,
            child:
                const Text(
              'Try again',
            ),
          ),
        ],
      );
    }

    if (_clientAppointments.isEmpty) {
      return const Card(
        child: Padding(
          padding:
              EdgeInsets.all(
            24,
          ),
          child: Column(
            children: [
              Icon(
                Icons
                    .calendar_month_outlined,
                size: 44,
                color:
                    AppTheme
                        .textSecondaryColor,
              ),

              SizedBox(
                height: 12,
              ),

              Text(
                'No appointments found.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              SizedBox(
                height: 6,
              ),

              Text(
                'You can create a new appointment for this client.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      AppTheme
                          .textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Client appointments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        ..._clientAppointments.map(
          (appointment) =>
              _ClientAppointmentCard(
            appointment:
                appointment,
            formattedDate:
                _formatDateTime(
              appointment
                  .startDateTime,
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(
    User user,
  ) {
    final first =
        user.firstName.isNotEmpty
            ? user.firstName[0]
            : '';

    final last =
        user.lastName.isNotEmpty
            ? user.lastName[0]
            : '';

    return '$first$last'
        .toUpperCase();
  }
}

class _ClientCard
    extends StatelessWidget {
  final User client;
  final VoidCallback onTap;

  const _ClientCard({
    required this.client,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      AppTheme
                          .accentColor
                          .withValues(
                    alpha: 0.12,
                  ),
                  child:
                      const Icon(
                    Icons.person_outline,
                    color:
                        AppTheme
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
                      Text(
                        '${client.firstName} ${client.lastName}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        client.email,
                        style:
                            const TextStyle(
                          fontSize: 13,
                          color:
                              AppTheme
                                  .textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color:
                      AppTheme
                          .textSecondaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientAppointmentCard
    extends StatelessWidget {
  final Appointment appointment;
  final String formattedDate;

  const _ClientAppointmentCard({
    required this.appointment,
    required this.formattedDate,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appointment
                          .serviceName,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  _StatusChip(
                    status:
                        appointment.status,
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  const Icon(
                    Icons
                        .schedule_outlined,
                    size: 18,
                    color:
                        AppTheme
                            .accentColor,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Text(
                    formattedDate,
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              Row(
                children: [
                  Icon(
                    appointment.isPaid
                        ? Icons
                            .check_circle_outline
                        : Icons
                            .info_outline,
                    size: 18,
                    color:
                        appointment.isPaid
                            ? Colors.green
                            : AppTheme
                                .textSecondaryColor,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Text(
                    appointment.isPaid
                        ? 'Paid'
                        : 'Not paid',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        return AppTheme.accentColor.withValues(
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