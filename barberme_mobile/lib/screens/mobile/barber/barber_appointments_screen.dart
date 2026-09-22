import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/appointment.dart';
import '../../../models/barber_service.dart';
import '../../../models/user.dart';
import '../../../services/appointment_service.dart';
import '../../../services/barber_service_service.dart';
import '../../../services/user_service.dart';
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

  final UserService _userService =
      UserService();

  final BarberServiceService _barberServiceService =
      BarberServiceService();

  List<Appointment> _appointments = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedListType = 'Upcoming';

  User? _selectedClient;
  BarberService? _selectedService;

  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();

    _loadAppointments();
  }

  bool get _hasActiveFilters {
    return _selectedClient != null ||
        _selectedService != null ||
        _dateFrom != null ||
        _dateTo != null;
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _appointmentService.getAppointments(
        clientId: _selectedClient?.id,
        serviceId: _selectedService?.serviceId,
        dateFrom: _dateFrom == null
            ? null
            : DateTime(
                _dateFrom!.year,
                _dateFrom!.month,
                _dateFrom!.day,
              ),
        dateTo: _dateTo == null
            ? null
            : DateTime(
                _dateTo!.year,
                _dateTo!.month,
                _dateTo!.day,
                23,
                59,
                59,
                999,
              ),
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

  Future<void> _openFilters() async {
    final result =
        await showModalBottomSheet<_AppointmentFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _AppointmentFilterSheet(
          initialClient: _selectedClient,
          initialService: _selectedService,
          initialDateFrom: _dateFrom,
          initialDateTo: _dateTo,
          userService: _userService,
          barberServiceService:
              _barberServiceService,
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _selectedClient = result.client;
      _selectedService = result.service;
      _dateFrom = result.dateFrom;
      _dateTo = result.dateTo;
    });

    await _loadAppointments();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedClient = null;
      _selectedService = null;
      _dateFrom = null;
      _dateTo = null;
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
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Filters',
                onPressed: _openFilters,
                icon: const Icon(
                  Icons.filter_alt_outlined,
                ),
              ),
              if (_hasActiveFilters)
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
                  const SizedBox(
                    width: 10,
                  ),
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

            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  2,
                  20,
                  6,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt_outlined,
                      size: 18,
                      color:
                          AppTheme.accentColor,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const Expanded(
                      child: Text(
                        'Filters applied',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme
                              .textSecondaryColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _clearFilters,
                      child:
                          const Text(
                        'Clear',
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
          padding: const EdgeInsets.all(
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
                height: 14,
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
                    _loadAppointments,
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

    if (_appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            _loadAppointments,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context)
                          .size
                          .height *
                      0.5,
              child: Center(
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
                        _hasActiveFilters
                            ? 'No appointments match the selected filters.'
                            : _selectedListType ==
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
                      if (_hasActiveFilters) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        OutlinedButton(
                          onPressed:
                              _clearFilters,
                          child:
                              const Text(
                            'Clear filters',
                          ),
                        ),
                      ],
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
      onRefresh:
          _loadAppointments,
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
            _appointments.length,
        separatorBuilder:
            (_, _) =>
                const SizedBox(
          height: 12,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          final appointment =
              _appointments[index];

          return _AppointmentCard(
            appointment:
                appointment,
            formattedDate:
                _formatDate(
              appointment.startDateTime,
            ),
            formattedStartTime:
                _formatTime(
              appointment.startDateTime,
            ),
            formattedEndTime:
                _formatTime(
              appointment.endDateTime,
            ),
            onTap: () async {
              await Navigator.of(context)
                  .push(
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

class _AppointmentFilters {
  final User? client;
  final BarberService? service;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const _AppointmentFilters({
    required this.client,
    required this.service,
    required this.dateFrom,
    required this.dateTo,
  });
}

class _AppointmentFilterSheet
    extends StatefulWidget {
  final User? initialClient;
  final BarberService? initialService;
  final DateTime? initialDateFrom;
  final DateTime? initialDateTo;

  final UserService userService;
  final BarberServiceService
      barberServiceService;

  const _AppointmentFilterSheet({
    required this.initialClient,
    required this.initialService,
    required this.initialDateFrom,
    required this.initialDateTo,
    required this.userService,
    required this.barberServiceService,
  });

  @override
  State<_AppointmentFilterSheet>
      createState() =>
          _AppointmentFilterSheetState();
}

class _AppointmentFilterSheetState
    extends State<_AppointmentFilterSheet> {
  final TextEditingController
      _clientSearchController =
      TextEditingController();

  User? _selectedClient;
  BarberService? _selectedService;

  DateTime? _dateFrom;
  DateTime? _dateTo;

  List<User> _clients = [];
  List<BarberService> _services = [];

  bool _isSearchingClients = false;
  bool _isLoadingServices = true;

  String? _clientSearchError;
  String? _serviceError;

  @override
  void initState() {
    super.initState();

    _selectedClient =
        widget.initialClient;

    _selectedService =
        widget.initialService;

    _dateFrom =
        widget.initialDateFrom;

    _dateTo =
        widget.initialDateTo;

    _loadServices();
  }

  @override
  void dispose() {
    _clientSearchController.dispose();

    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoadingServices = true;
      _serviceError = null;
    });

    try {
      final barber =
          await widget.userService
              .getCurrentUser();

      final services =
          await widget.barberServiceService
              .getForBooking(
        barber.id,
      );

      if (!mounted) return;

      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _serviceError =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoadingServices = false;
      });
    }
  }

  Future<void> _searchClients() async {
    final search =
        _clientSearchController.text
            .trim();

    if (search.isEmpty) {
      setState(() {
        _clients = [];
        _clientSearchError = null;
      });

      return;
    }

    setState(() {
      _isSearchingClients = true;
      _clientSearchError = null;
    });

    try {
      final result =
          await widget.userService
              .getClients(
        fts: search,
        page: 1,
        pageSize: 20,
      );

      if (!mounted) return;

      setState(() {
        _clients = result.items;
        _isSearchingClients = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _clientSearchError =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isSearchingClients = false;
      });
    }
  }

  Future<void> _selectDateFrom() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          _dateFrom ?? DateTime.now(),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime.now().add(
        const Duration(
          days: 730,
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _dateFrom = selected;

      if (_dateTo != null &&
          _dateTo!.isBefore(
            selected,
          )) {
        _dateTo = selected;
      }
    });
  }

  Future<void> _selectDateTo() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          _dateTo ??
              _dateFrom ??
              DateTime.now(),
      firstDate:
          _dateFrom ??
              DateTime(2020),
      lastDate:
          DateTime.now().add(
        const Duration(
          days: 730,
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _dateTo = selected;
    });
  }

  void _clearLocalFilters() {
    setState(() {
      _selectedClient = null;
      _selectedService = null;
      _dateFrom = null;
      _dateTo = null;

      _clients = [];
      _clientSearchController.clear();
    });
  }

  String _formatDate(
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

    return '$day.$month.${value.year}.';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bottomInset =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context)
                    .size
                    .height *
                0.9,
      ),
      decoration:
          const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top:
              Radius.circular(
            24,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(
            20,
            14,
            20,
            20 + bottomInset,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration:
                    BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter appointments',
                      style:
                          TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip:
                        'Close',
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                    icon:
                        const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Client',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      if (_selectedClient !=
                          null)
                        _SelectedFilterCard(
                          icon:
                              Icons.person_outline,
                          title:
                              '${_selectedClient!.firstName} ${_selectedClient!.lastName}',
                          subtitle:
                              _selectedClient!.email,
                          onClear: () {
                            setState(() {
                              _selectedClient =
                                  null;
                              _clients = [];
                              _clientSearchController
                                  .clear();
                            });
                          },
                        )
                      else ...[
                        TextField(
                          controller:
                              _clientSearchController,
                          textInputAction:
                              TextInputAction.search,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Search client',
                            prefixIcon:
                                const Icon(
                              Icons.search,
                            ),
                            suffixIcon:
                                _isSearchingClients
                                    ? const Padding(
                                        padding:
                                            EdgeInsets.all(
                                          14,
                                        ),
                                        child:
                                            SizedBox(
                                          width:
                                              18,
                                          height:
                                              18,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        tooltip:
                                            'Search',
                                        onPressed:
                                            _searchClients,
                                        icon:
                                            const Icon(
                                          Icons.search,
                                        ),
                                      ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                          onSubmitted:
                              (_) {
                            _searchClients();
                          },
                        ),

                        if (_clientSearchError !=
                            null) ...[
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            _clientSearchError!,
                            style:
                                const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ],

                        if (_clients
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            constraints:
                                const BoxConstraints(
                              maxHeight:
                                  190,
                            ),
                            decoration:
                                BoxDecoration(
                              border:
                                  Border.all(
                                color: Colors
                                    .grey
                                    .shade300,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                            child:
                                ListView.separated(
                              shrinkWrap:
                                  true,
                              itemCount:
                                  _clients.length,
                              separatorBuilder:
                                  (_, _) =>
                                      const Divider(
                                height:
                                    1,
                              ),
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final client =
                                    _clients[index];

                                return ListTile(
                                  leading:
                                      const Icon(
                                    Icons
                                        .person_outline,
                                  ),
                                  title:
                                      Text(
                                    '${client.firstName} ${client.lastName}',
                                  ),
                                  subtitle:
                                      Text(
                                    client.email,
                                  ),
                                  onTap:
                                      () {
                                    setState(() {
                                      _selectedClient =
                                          client;
                                      _clients =
                                          [];
                                      _clientSearchController
                                          .clear();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(
                        height: 22,
                      ),

                      const Text(
                        'Service',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      if (_isLoadingServices)
                        const Center(
                          child:
                              Padding(
                            padding:
                                EdgeInsets.symmetric(
                              vertical:
                                  20,
                            ),
                            child:
                                CircularProgressIndicator(),
                          ),
                        )
                      else if (_serviceError !=
                          null)
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              _serviceError!,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.red,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            OutlinedButton(
                              onPressed:
                                  _loadServices,
                              child:
                                  const Text(
                                'Try again',
                              ),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<
                            BarberService>(
                          initialValue:
                              _selectedService,
                          isExpanded:
                              true,
                          decoration:
                              InputDecoration(
                            hintText:
                                'All services',
                            prefixIcon:
                                const Icon(
                              Icons.content_cut,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                          items: _services
                              .map(
                                (
                                  service,
                                ) {
                                  return DropdownMenuItem<
                                      BarberService>(
                                    value:
                                        service,
                                    child:
                                        Text(
                                      service
                                          .serviceName,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  );
                                },
                              )
                              .toList(),
                          onChanged:
                              (value) {
                            setState(() {
                              _selectedService =
                                  value;
                            });
                          },
                        ),

                      if (_selectedService !=
                          null) ...[
                        const SizedBox(
                          height: 8,
                        ),
                        Align(
                          alignment:
                              Alignment.centerRight,
                          child:
                              TextButton(
                            onPressed:
                                () {
                              setState(() {
                                _selectedService =
                                    null;
                              });
                            },
                            child:
                                const Text(
                              'Clear service',
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 18,
                      ),

                      const Text(
                        'Period',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _DateFilterField(
                              label:
                                  'Date from',
                              value:
                                  _dateFrom ==
                                          null
                                      ? null
                                      : _formatDate(
                                          _dateFrom!,
                                        ),
                              onTap:
                                  _selectDateFrom,
                              onClear:
                                  _dateFrom ==
                                          null
                                      ? null
                                      : () {
                                          setState(() {
                                            _dateFrom =
                                                null;
                                          });
                                        },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                                _DateFilterField(
                              label:
                                  'Date to',
                              value:
                                  _dateTo ==
                                          null
                                      ? null
                                      : _formatDate(
                                          _dateTo!,
                                        ),
                              onTap:
                                  _selectDateTo,
                              onClear:
                                  _dateTo ==
                                          null
                                      ? null
                                      : () {
                                          setState(() {
                                            _dateTo =
                                                null;
                                          });
                                        },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 28,
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton(
                      onPressed:
                          _clearLocalFilters,
                      child:
                          const Text(
                        'Clear filters',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child:
                        FilledButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop(
                          _AppointmentFilters(
                            client:
                                _selectedClient,
                            service:
                                _selectedService,
                            dateFrom:
                                _dateFrom,
                            dateTo:
                                _dateTo,
                          ),
                        );
                      },
                      child:
                          const Text(
                        'Apply filters',
                      ),
                    ),
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

class _SelectedFilterCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onClear;

  const _SelectedFilterCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onClear,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        border:
            Border.all(
          color:
              AppTheme.accentColor.withValues(
            alpha: 0.4,
          ),
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
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
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                if (subtitle !=
                        null &&
                    subtitle!.isNotEmpty) ...[
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    subtitle!,
                    style:
                        const TextStyle(
                      fontSize:
                          13,
                      color: AppTheme
                          .textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed:
                onClear,
            tooltip:
                'Clear',
            icon:
                const Icon(
              Icons.close,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFilterField
    extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        14,
      ),
      child: InputDecorator(
        decoration:
            InputDecoration(
          labelText:
              label,
          prefixIcon:
              const Icon(
            Icons
                .calendar_today_outlined,
          ),
          suffixIcon:
              value != null
                  ? IconButton(
                      tooltip:
                          'Clear',
                      onPressed:
                          onClear,
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
        child: Text(
          value ??
              'Select',
          style:
              TextStyle(
            color:
                value == null
                    ? AppTheme
                        .textSecondaryColor
                    : null,
          ),
        ),
      ),
    );
  }
}

class _FilterButton
    extends StatelessWidget {
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
        onPressed:
            onPressed,
        child:
            Text(
          text,
        ),
      );
    }

    return OutlinedButton(
      onPressed:
          onPressed,
      child:
          Text(
        text,
      ),
    );
  }
}

class _AppointmentCard
    extends StatelessWidget {
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
        onTap:
            onTap,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
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
                  CircleAvatar(
                    radius:
                        24,
                    backgroundColor:
                        AppTheme.accentColor
                            .withValues(
                      alpha:
                          0.12,
                    ),
                    child:
                        const Icon(
                      Icons.person_outline,
                      color:
                          AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(
                    width:
                        14,
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
                            fontSize:
                                17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height:
                              4,
                        ),
                        Text(
                          appointment
                              .serviceName,
                          style:
                              const TextStyle(
                            color:
                                AppTheme.textSecondaryColor,
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

              const SizedBox(
                height:
                    16,
              ),

              Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_today_outlined,
                    size:
                        18,
                    color:
                        AppTheme.accentColor,
                  ),
                  const SizedBox(
                    width:
                        8,
                  ),
                  Text(
                    formattedDate,
                  ),
                ],
              ),

              const SizedBox(
                height:
                    9,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size:
                        18,
                    color:
                        AppTheme.accentColor,
                  ),
                  const SizedBox(
                    width:
                        8,
                  ),
                  Text(
                    '$formattedStartTime - '
                    '$formattedEndTime',
                  ),
                ],
              ),

              const SizedBox(
                height:
                    9,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size:
                        18,
                    color:
                        AppTheme.accentColor,
                  ),
                  const SizedBox(
                    width:
                        8,
                  ),
                  Text(
                    '${appointment.finalPrice.toStringAsFixed(2)} BAM',
                  ),
                  const Spacer(),
                  Text(
                    appointment.isPaid
                        ? 'Paid'
                        : 'Not paid',
                    style:
                        TextStyle(
                      fontSize:
                          13,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          appointment.isPaid
                              ? Colors.green
                              : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                    12,
              ),

              const Align(
                alignment:
                    Alignment.centerRight,
                child:
                    Icon(
                  Icons.chevron_right,
                  color:
                      AppTheme.textSecondaryColor,
                ),
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
    switch (
        status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.withValues(
          alpha:
              0.12,
        );

      case 'cancelled':
      case 'no show':
      case 'noshow':
        return Colors.red.withValues(
          alpha:
              0.12,
        );

      case 'completed':
        return Colors.blueGrey.withValues(
          alpha:
              0.12,
        );

      default:
        return AppTheme.accentColor.withValues(
          alpha:
              0.12,
        );
    }
  }

  Color _foregroundColor() {
    switch (
        status.toLowerCase()) {
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
        horizontal:
            9,
        vertical:
            5,
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
          fontSize:
              11,
          fontWeight:
              FontWeight.w600,
          color:
              _foregroundColor(),
        ),
      ),
    );
  }
}