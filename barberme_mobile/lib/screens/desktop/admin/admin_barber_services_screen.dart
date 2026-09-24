import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/barber_service.dart';
import '../../../models/service.dart';
import '../../../models/user.dart';
import '../../../services/barber_service_service.dart';
import '../../../services/service_service.dart';

class AdminBarberServicesScreen extends StatefulWidget {
  final User barber;

  const AdminBarberServicesScreen({
    super.key,
    required this.barber,
  });

  @override
  State<AdminBarberServicesScreen> createState() =>
      _AdminBarberServicesScreenState();
}

class _AdminBarberServicesScreenState
    extends State<AdminBarberServicesScreen> {
  final BarberServiceService _barberServiceService =
      BarberServiceService();

  final ServiceService _serviceService =
      ServiceService();

  bool _isLoading = true;
  String? _errorMessage;

  List<BarberService> _barberServices = [];

  int _page = 1;
  final int _pageSize = 10;

  int _totalCount = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadBarberServices();
  }

  Future<void> _loadBarberServices({
    int? page,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _barberServiceService
              .getBarberServices(
        barberId: widget.barber.id,
        page: page ?? _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _barberServices = result.items;
        _page = result.page;
        _totalCount = result.totalCount;
        _totalPages = result.totalPages;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAddServiceDialog() async {
    try {
      final result =
          await _serviceService.getServices(
        page: 1,
        pageSize: 100,
      );

      if (!mounted) {
        return;
      }

      final assignedServiceIds =
          _barberServices
              .map((x) => x.serviceId)
              .toSet();

      final availableServices =
          result.items.where((service) {
        return service.isActive &&
            !assignedServiceIds.contains(
              service.id,
            );
      }).toList();

      if (availableServices.isEmpty) {
        _showMessage(
          'There are no available services to assign.',
        );
        return;
      }

      final created =
          await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _AddBarberServiceDialog(
          barber: widget.barber,
          services: availableServices,
          barberServiceService:
              _barberServiceService,
        ),
      );

      if (created == true) {
        _page = 1;

        await _loadBarberServices(
          page: 1,
        );

        if (!mounted) {
          return;
        }

        _showMessage(
          'Service assigned successfully.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    }
  }

  Future<void> _openEditDialog(
    BarberService barberService,
  ) async {
    final updated =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditBarberServiceDialog(
        barberService: barberService,
        barberServiceService:
            _barberServiceService,
      ),
    );

    if (updated == true) {
      await _loadBarberServices(
        page: _page,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Service updated successfully.',
      );
    }
  }

  Future<void> _removeService(
    BarberService barberService,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove service',
          ),
          content: Text(
            'Remove "${barberService.serviceName}" '
            'from ${widget.barber.firstName} '
            '${widget.barber.lastName}?',
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
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _barberServiceService
          .deleteBarberService(
        barberService.id,
      );

      if (!mounted) {
        return;
      }

      var targetPage = _page;

      if (_barberServices.length == 1 &&
          _page > 1) {
        targetPage = _page - 1;
      }

      await _loadBarberServices(
        page: targetPage,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Service removed successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor:
            AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Barber Services',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.barber.firstName} '
                '${widget.barber.lastName}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color:
                      AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage services, individual prices and durations.',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _isLoading
              ? null
              : _openAddServiceDialog,
          icon: const Icon(
            Icons.add,
          ),
          label: const Text(
            'Add service',
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 46,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed:
                  _loadBarberServices,
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildTable(),
        ),
        const SizedBox(height: 18),
        _buildPagination(),
      ],
    );
  }

  Widget _buildTable() {
    if (_barberServices.isEmpty) {
      return const Center(
        child: Text(
          'No services assigned to this barber.',
          style: TextStyle(
            color:
                AppTheme.textSecondaryColor,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFFE5E1DC,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor:
                WidgetStateProperty.all(
              const Color(0xFFF2EFEA),
            ),
            columns: const [
              DataColumn(
                label: Text('Service'),
              ),
              DataColumn(
                label: Text('Price'),
              ),
              DataColumn(
                label: Text('Duration'),
              ),
              DataColumn(
                label: Text('Status'),
              ),
              DataColumn(
                label: Text('Actions'),
              ),
            ],
            rows: _barberServices
                .map(_buildServiceRow)
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildServiceRow(
    BarberService barberService,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            barberService.serviceName,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
        DataCell(
          Text(
            '${barberService.price.toStringAsFixed(2)} BAM',
          ),
        ),
        DataCell(
          Text(
            '${barberService.durationMinutes} min',
          ),
        ),
        DataCell(
          _buildStatusBadge(
            barberService.isActive,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () {
                  _openEditDialog(
                    barberService,
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),
              IconButton(
                tooltip: 'Remove',
                onPressed: () {
                  _removeService(
                    barberService,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(
    bool isActive,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFEAF7ED)
            : const Color(0xFFF2F2F2),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive
              ? const Color(0xFF28783A)
              : const Color(0xFF777777),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final from = _totalCount == 0
        ? 0
        : ((_page - 1) * _pageSize) + 1;

    final calculatedTo =
        _page * _pageSize;

    final to =
        calculatedTo > _totalCount
            ? _totalCount
            : calculatedTo;

    return Row(
      children: [
        Text(
          'Showing $from-$to of '
          '$_totalCount services',
          style: const TextStyle(
            color:
                AppTheme.textSecondaryColor,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: _page > 1
              ? () {
                  _loadBarberServices(
                    page: _page - 1,
                  );
                }
              : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Text(
            'Page $_page of '
            '${_totalPages == 0 ? 1 : _totalPages}',
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: _page < _totalPages
              ? () {
                  _loadBarberServices(
                    page: _page + 1,
                  );
                }
              : null,
          icon: const Icon(
            Icons.chevron_right,
          ),
        ),
      ],
    );
  }
}

class _AddBarberServiceDialog
    extends StatefulWidget {
  final User barber;
  final List<Service> services;

  final BarberServiceService
      barberServiceService;

  const _AddBarberServiceDialog({
    required this.barber,
    required this.services,
    required this.barberServiceService,
  });

  @override
  State<_AddBarberServiceDialog>
      createState() =>
          _AddBarberServiceDialogState();
}

class _AddBarberServiceDialogState
    extends State<_AddBarberServiceDialog> {
  final _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _priceController =
      TextEditingController();

  final TextEditingController
      _durationController =
      TextEditingController();

  Service? _selectedService;

  bool _isSaving = false;

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  void _selectService(
    Service? service,
  ) {
    setState(() {
      _selectedService = service;
    });

    if (service != null) {
      _priceController.text =
          service.defaultPrice
              .toStringAsFixed(2);

      _durationController.text =
          service.defaultDurationMinutes
              .toString();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_selectedService == null) {
      return;
    }

    final price = double.tryParse(
      _priceController.text
          .trim()
          .replaceAll(',', '.'),
    );

    final duration = int.tryParse(
      _durationController.text.trim(),
    );

    if (price == null ||
        duration == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.barberServiceService
          .createBarberService(
        barberId: widget.barber.id,
        serviceId:
            _selectedService!.id,
        price: price,
        durationMinutes: duration,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add service',
      ),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              DropdownButtonFormField<Service>(
                initialValue:
                    _selectedService,
                decoration:
                    const InputDecoration(
                  labelText: 'Service',
                ),
                items: widget.services
                    .map(
                      (service) =>
                          DropdownMenuItem<
                              Service>(
                        value: service,
                        child: Text(
                          service.name,
                        ),
                      ),
                    )
                    .toList(),
                onChanged:
                    _isSaving
                        ? null
                        : _selectService,
                validator: (value) {
                  if (value == null) {
                    return 'Select a service.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _priceController,
                enabled: !_isSaving,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'Price (BAM)',
                ),
                validator: (value) {
                  final parsed =
                      double.tryParse(
                    (value ?? '')
                        .replaceAll(
                          ',',
                          '.',
                        ),
                  );

                  if (parsed == null ||
                      parsed <= 0) {
                    return 'Enter a valid price.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _durationController,
                enabled: !_isSaving,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Duration (minutes)',
                ),
                validator: (value) {
                  final parsed =
                      int.tryParse(
                    value ?? '',
                  );

                  if (parsed == null ||
                      parsed < 1 ||
                      parsed > 1000) {
                    return 'Duration must be between 1 and 1000 minutes.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context)
                      .pop(false);
                },
          child: const Text(
            'Cancel',
          ),
        ),
        FilledButton(
          onPressed:
              _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Add',
                ),
        ),
      ],
    );
  }
}

class _EditBarberServiceDialog
    extends StatefulWidget {
  final BarberService barberService;

  final BarberServiceService
      barberServiceService;

  const _EditBarberServiceDialog({
    required this.barberService,
    required this.barberServiceService,
  });

  @override
  State<_EditBarberServiceDialog>
      createState() =>
          _EditBarberServiceDialogState();
}

class _EditBarberServiceDialogState
    extends State<_EditBarberServiceDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _priceController;

  late final TextEditingController
      _durationController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _priceController =
        TextEditingController(
      text: widget.barberService.price
          .toStringAsFixed(2),
    );

    _durationController =
        TextEditingController(
      text: widget
          .barberService
          .durationMinutes
          .toString(),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final price = double.tryParse(
      _priceController.text
          .trim()
          .replaceAll(',', '.'),
    );

    final duration = int.tryParse(
      _durationController.text.trim(),
    );

    if (price == null ||
        duration == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.barberServiceService
          .updateBarberService(
        id: widget.barberService.id,
        price: price,
        durationMinutes: duration,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit ${widget.barberService.serviceName}',
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextFormField(
                controller:
                    _priceController,
                enabled: !_isSaving,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'Price (BAM)',
                ),
                validator: (value) {
                  final parsed =
                      double.tryParse(
                    (value ?? '')
                        .replaceAll(
                          ',',
                          '.',
                        ),
                  );

                  if (parsed == null ||
                      parsed <= 0) {
                    return 'Enter a valid price.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller:
                    _durationController,
                enabled: !_isSaving,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Duration (minutes)',
                ),
                validator: (value) {
                  final parsed =
                      int.tryParse(
                    value ?? '',
                  );

                  if (parsed == null ||
                      parsed < 1 ||
                      parsed > 1000) {
                    return 'Duration must be between 1 and 1000 minutes.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context)
                      .pop(false);
                },
          child: const Text(
            'Cancel',
          ),
        ),
        FilledButton(
          onPressed:
              _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save',
                ),
        ),
      ],
    );
  }
}