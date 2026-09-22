import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/service.dart';
import '../../../services/service_service.dart';
import 'add_service_dialog.dart';
import 'edit_service_dialog.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() =>
      _AdminServicesScreenState();
}

class _AdminServicesScreenState
    extends State<AdminServicesScreen> {
  final ServiceService _serviceService =
      ServiceService();

  final TextEditingController _searchController =
      TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  List<Service> _services = [];

  int _page = 1;
  final int _pageSize = 10;

  int _totalCount = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices({
    int? page,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _serviceService.getServices(
        fts: _searchController.text.trim(),
        page: page ?? _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _services = result.items;
        _page = result.page;
        _totalCount = result.totalCount;
        _totalPages = result.totalPages;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString().replaceFirst(
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

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : null,
      ),
    );
  }

  void _search() {
    _page = 1;

    _loadServices(
      page: 1,
    );
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _page = 1;
    });

    _loadServices(
      page: 1,
    );
  }

  Future<void> _changeServiceStatus(
    Service service,
  ) async {
    final activating = !service.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            activating
                ? 'Activate service'
                : 'Deactivate service',
          ),
          content: Text(
            activating
                ? 'Are you sure you want to activate "${service.name}"?'
                : 'Are you sure you want to deactivate "${service.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                activating
                    ? 'Activate'
                    : 'Deactivate',
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
      if (activating) {
        await _serviceService.activateService(
          service.id,
        );
      } else {
        await _serviceService.deactivateService(
          service.id,
        );
      }

      await _loadServices(
        page: _page,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        activating
            ? 'Service activated successfully.'
            : 'Service deactivated successfully.',
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

  Future<void> _deleteService(
    Service service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete service',
          ),
          content: Text(
            'Are you sure you want to permanently delete '
            '"${service.name}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _serviceService.deleteService(
        service.id,
      );

      // If the last item on the page was deleted,
      // go back one page when possible.
      var pageToLoad = _page;

      if (_services.length == 1 && _page > 1) {
        pageToLoad = _page - 1;
      }

      await _loadServices(
        page: pageToLoad,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Service deleted successfully.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to codebooks',
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: const Text(
          'Services',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          32,
          12,
          32,
          32,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildFilters(),
            const SizedBox(height: 20),
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
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Services',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color:
                      AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage salon services, prices and durations.',
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
              : () async {
                  final created =
                      await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const AddServiceDialog(),
                  );

                  if (created != true) {
                    return;
                  }

                  _page = 1;

                  await _loadServices(
                    page: 1,
                  );

                  if (!mounted) {
                    return;
                  }

                  _showMessage(
                    'Service created successfully.',
                  );
                },
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E1DC),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) {
                _search();
              },
              decoration:
                  const InputDecoration(
                hintText:
                    'Search services...',
                prefixIcon: Icon(
                  Icons.search,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed:
                _isLoading ? null : _search,
            icon: const Icon(
              Icons.search,
            ),
            label: const Text(
              'Search',
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: _isLoading
                ? null
                : _clearFilters,
            child: const Text(
              'Clear',
            ),
          ),
        ],
      ),
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
              onPressed: _loadServices,
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
    if (_services.isEmpty) {
      return const Center(
        child: Text(
          'No services found.',
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
          color: const Color(0xFFE5E1DC),
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
                label: Text('Description'),
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
            rows: _services
                .map(_buildServiceRow)
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildServiceRow(
    Service service,
  ) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 170,
            child: Row(
              children: [
                _buildServiceImage(service),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    service.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 230,
            child: Text(
              service.description
                          ?.trim()
                          .isNotEmpty ==
                      true
                  ? service.description!
                  : '-',
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Text(
            '${service.defaultPrice.toStringAsFixed(2)} KM',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DataCell(
          Text(
            '${service.defaultDurationMinutes} min',
          ),
        ),
        DataCell(
          _buildStatusBadge(
            service.isActive,
          ),
        ),
        DataCell(
          PopupMenuButton<String>(
            tooltip: 'Service actions',
            onSelected: (value) async {
              if (value == 'edit') {
                final updated = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => EditServiceDialog(
                    service: service,
                  ),
                );

                if (updated != true) {
                  return;
                }

                await _loadServices(
                  page: _page,
                );

                if (!mounted) {
                  return;
                }

                _showMessage(
                  'Service updated successfully.',
                );
              }

              if (value == 'status') {
                await _changeServiceStatus(service);
              }

              if (value == 'delete') {
                await _deleteService(service);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 19,
                    ),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    Icon(
                      service.isActive
                          ? Icons.block_outlined
                          : Icons.check_circle_outline,
                      size: 19,
                      color: service.isActive
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      service.isActive
                          ? 'Deactivate'
                          : 'Activate',
                    ),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 19,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceImage(
    Service service,
  ) {
    final imageUrl = service.imageUrl?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildServiceImagePlaceholder();
    }

    final url = imageUrl.startsWith('http')
        ? imageUrl
        : '${ApiConfig.baseUrl}/${imageUrl.replaceFirst(RegExp(r'^/+'), '')}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _buildServiceImagePlaceholder();
        },
      ),
    );
  }

  Widget _buildServiceImagePlaceholder() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.content_cut,
        size: 19,
        color: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildStatusBadge(
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
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
        isActive
            ? 'Active'
            : 'Inactive',
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

    final to = calculatedTo > _totalCount
        ? _totalCount
        : calculatedTo;

    return Row(
      children: [
        Text(
          'Showing $from-$to of $_totalCount services',
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
                  _loadServices(
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
            'Page $_page of ${_totalPages == 0 ? 1 : _totalPages}',
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed:
              _page < _totalPages
                  ? () {
                      _loadServices(
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