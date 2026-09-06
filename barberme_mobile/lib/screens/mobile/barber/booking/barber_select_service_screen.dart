import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/barber_service.dart';
import '../../../../models/user.dart';
import '../../../../services/barber_service_service.dart';

import 'barber_select_date_time_screen.dart';

class BarberSelectServiceScreen extends StatefulWidget {
  final User client;
  final User barber;

  const BarberSelectServiceScreen({
    super.key,
    required this.client,
    required this.barber,
  });

  @override
  State<BarberSelectServiceScreen> createState() =>
      _BarberSelectServiceScreenState();
}

class _BarberSelectServiceScreenState
    extends State<BarberSelectServiceScreen> {
  final BarberServiceService _service =
      BarberServiceService();

  List<BarberService> _services = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final services = await _service.getForBooking(
        widget.barber.id,
      );

      if (!mounted) return;

      setState(() {
        _services = services;
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

  @override
  Widget build(BuildContext context) {
    final clientName =
        '${widget.client.firstName} ${widget.client.lastName}'
            .trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              4,
            ),
            child: Text(
              'Creating appointment for $clientName',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
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
                    _loadServices,
                child: const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_services.isEmpty) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(
            24,
          ),
          child: Text(
            'You currently have no available services.',
            textAlign:
                TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          _loadServices,
      child: ListView.separated(
        padding:
            const EdgeInsets.all(
          20,
        ),
        itemCount:
            _services.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(
          height: 12,
        ),
        itemBuilder:
            (context, index) {
          final service =
              _services[index];

          return Card(
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        BarberSelectDateTimeScreen(
                      client:
                          widget.client,
                      barber:
                          widget.barber,
                      barberService:
                          service,
                    ),
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor:
                          AppTheme
                              .accentColor
                              .withValues(
                        alpha: 0.12,
                      ),
                      child:
                          const Icon(
                        Icons.content_cut,
                        color:
                            AppTheme
                                .accentColor,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            service
                                .serviceName,
                            style:
                                const TextStyle(
                              fontSize:
                                  17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .schedule_outlined,
                                size: 17,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '${service.durationMinutes} min',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .end,
                      children: [
                        Text(
                          '${service.price.toStringAsFixed(2)} BAM',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize:
                                16,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Icon(
                          Icons.chevron_right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}