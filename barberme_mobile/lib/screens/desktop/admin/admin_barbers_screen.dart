import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';
import 'admin_barber_services_screen.dart';
import 'admin_barber_working_hours_screen.dart';

class AdminBarbersScreen extends StatefulWidget {
  const AdminBarbersScreen({super.key});

  @override
  State<AdminBarbersScreen> createState() =>
      _AdminBarbersScreenState();
}

class _AdminBarbersScreenState
    extends State<AdminBarbersScreen> {
  final UserService _userService = UserService();

  final TextEditingController _searchController =
      TextEditingController();

  static const int _barberRoleId = 2;

  bool _isLoading = true;
  String? _errorMessage;

  List<User> _barbers = [];

  int _page = 1;
  final int _pageSize = 10;

  int _totalCount = 0;
  int _totalPages = 0;

  bool? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadBarbers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBarbers({
    int? page,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _userService.getUsers(
        fts: _searchController.text.trim(),
        roleId: _barberRoleId,
        isActive: _selectedStatus,
        page: page ?? _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _barbers = result.items;
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

  void _search() {
    _page = 1;

    _loadBarbers(
      page: 1,
    );
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _selectedStatus = null;
      _page = 1;
    });

    _loadBarbers(
      page: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Barbers',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Manage barber services and working schedules.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
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
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                _search();
              },
              decoration: const InputDecoration(
                hintText: 'Search barber...',
                prefixIcon: Icon(
                  Icons.search,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<bool?>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: const [
                DropdownMenuItem<bool?>(
                  value: null,
                  child: Text('All statuses'),
                ),
                DropdownMenuItem<bool?>(
                  value: true,
                  child: Text('Active'),
                ),
                DropdownMenuItem<bool?>(
                  value: false,
                  child: Text('Inactive'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                  _page = 1;
                });

                _loadBarbers(
                  page: 1,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: _isLoading ? null : _search,
            icon: const Icon(
              Icons.search,
            ),
            label: const Text(
              'Search',
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed:
                _isLoading ? null : _clearFilters,
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
              onPressed: _loadBarbers,
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
    if (_barbers.isEmpty) {
      return const Center(
        child: Text(
          'No barbers found.',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E1DC),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor:
                WidgetStateProperty.all(
              const Color(0xFFF2EFEA),
            ),
            columns: const [
              DataColumn(
                label: Text('Barber'),
              ),
              DataColumn(
                label: Text('Email'),
              ),
              DataColumn(
                label: Text('Phone'),
              ),
              DataColumn(
                label: Text('Level'),
              ),
              DataColumn(
                label: Text('Status'),
              ),
              DataColumn(
                label: Text('Actions'),
              ),
            ],
            rows: _barbers
                .map(_buildBarberRow)
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildBarberRow(
    User barber,
  ) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 180,
            child: Row(
              children: [
                _buildBarberAvatar(barber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${barber.firstName} '
                    '${barber.lastName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Text(barber.email),
        ),
        DataCell(
          Text(
            barber.phoneNumber.isEmpty
                ? '-'
                : barber.phoneNumber,
          ),
        ),
        DataCell(
          _buildLevelBadge(
            barber.barberLevel?.name,
          ),
        ),
        DataCell(
          _buildStatusBadge(
            barber.isActive,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminBarberServicesScreen(
                        barber: barber,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.design_services_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Services',
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminBarberWorkingHoursScreen(
                        barber: barber,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.schedule_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Working hours',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelBadge(
    String? level,
  ) {
    final value =
        level == null || level.trim().isEmpty
            ? 'Not assigned'
            : level;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppTheme.accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
        borderRadius: BorderRadius.circular(20),
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

  void _showComingSoon(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String? _getProfileImageUrl(
    User barber,
  ) {
    final path = barber.profileImagePath;

    if (path == null || path.trim().isEmpty) {
      return null;
    }

    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    final normalizedPath = path
        .replaceAll('\\', '/')
        .replaceFirst(
          RegExp(r'^/+'),
          '',
        );

    return '${ApiConfig.baseUrl}/$normalizedPath';
  }

  String _initials(
    User barber,
  ) {
    final first = barber.firstName.isNotEmpty
        ? barber.firstName[0]
        : '';

    final last = barber.lastName.isNotEmpty
        ? barber.lastName[0]
        : '';

    return '$first$last'.toUpperCase();
  }

  Widget _buildBarberAvatar(
    User barber,
  ) {
    final imageUrl =
        _getProfileImageUrl(barber);

    if (imageUrl == null) {
      return _buildInitialsAvatar(barber);
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _buildInitialsAvatar(
            barber,
          );
        },
      ),
    );
  }

  Widget _buildInitialsAvatar(
    User barber,
  ) {
    return CircleAvatar(
      radius: 21,
      backgroundColor:
          AppTheme.primaryColor,
      child: Text(
        _initials(barber),
        style: const TextStyle(
          color: Colors.white,
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
          'Showing $from-$to of $_totalCount barbers',
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: _page > 1
              ? () {
                  _loadBarbers(
                    page: _page - 1,
                  );
                }
              : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Text(
            'Page $_page of '
            '${_totalPages == 0 ? 1 : _totalPages}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: _page < _totalPages
              ? () {
                  _loadBarbers(
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