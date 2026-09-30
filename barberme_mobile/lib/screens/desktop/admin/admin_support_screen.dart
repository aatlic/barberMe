import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/support_request.dart';
import '../../../services/support_request_service.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  final SupportRequestService _service = SupportRequestService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  List<SupportRequest> _requests = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalCount = 0;

  int? _selectedStatus;

  int get _totalPages {
    if (_totalCount == 0) return 1;
    return (_totalCount / _pageSize).ceil();
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getSupportRequests(
        fts: _searchController.text.trim(),
        status: _selectedStatus,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _requests = result.items;
        _totalCount = result.totalCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _currentPage = 1;
      _loadRequests();
    });
  }

  void _changeStatusFilter(int? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });

    _loadRequests();
  }

  Future<void> _openDetails(SupportRequest request) async {
    SupportRequest selectedRequest = request;

    try {
      selectedRequest = await _service.getSupportRequestById(request.id);
    } catch (_) {
      // The row already contains the data required for the dialog.
    }

    if (!mounted) return;

    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _SupportRequestDetailsDialog(
          request: selectedRequest,
          service: _service,
        );
      },
    );

    if (changed == true) {
      await _loadRequests();
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case 1:
        return const Color(0xFFB26A00);
      case 2:
        return const Color(0xFF2D6A9F);
      case 3:
        return const Color(0xFF3E7A4A);
      default:
        return Colors.grey;
    }
  }

  Color _statusBackground(int status) {
    switch (status) {
      case 1:
        return const Color(0xFFFFF3E0);
      case 2:
        return const Color(0xFFEAF3FA);
      case 3:
        return const Color(0xFFEAF5EC);
      default:
        return const Color(0xFFF2F2F2);
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(local.day)}.${two(local.month)}.${local.year}. '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F5F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                children: [
                  _buildFilters(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildContent(),
                  ),
                  if (!_isLoading &&
                      _errorMessage == null &&
                      _requests.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildPagination(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFA67C52).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFA67C52),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review and manage customer support requests.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E3DD),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by subject or message...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _currentPage = 1;
                          });
                          _loadRequests();
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9F8F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 190,
            child: DropdownButtonFormField<int?>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                filled: true,
                fillColor: const Color(0xFFF9F8F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All statuses'),
                ),
                DropdownMenuItem<int?>(
                  value: 1,
                  child: Text('Open'),
                ),
                DropdownMenuItem<int?>(
                  value: 2,
                  child: Text('In Progress'),
                ),
                DropdownMenuItem<int?>(
                  value: 3,
                  child: Text('Closed'),
                ),
              ],
              onChanged: _changeStatusFilter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFA67C52),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFB85C5C),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E3DD),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 54,
                color: Color(0xFFB7B1AA),
              ),
              SizedBox(height: 14),
              Text(
                'No support requests found.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildTable();
  }

  Widget _buildTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E3DD),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF2EFEA),
              ),
              columnSpacing: 28,
              columns: const [
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Subject')),
                DataColumn(label: Text('Created')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _requests.map(_buildRow).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(SupportRequest request) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 210,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  request.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
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
              request.subject,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Text(
            _formatDate(request.createdAt),
            style: const TextStyle(
              color: Color(0xFF666666),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _statusBackground(request.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              request.statusName,
              style: TextStyle(
                color: _statusColor(request.status),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'View details',
            child: IconButton(
              onPressed: () => _openDetails(request),
              icon: const Icon(
                Icons.visibility_outlined,
                color: Color(0xFFA67C52),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      children: [
        Text(
          '$_totalCount request${_totalCount == 1 ? '' : 's'}',
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                  _loadRequests();
                }
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE0DBD5),
            ),
          ),
          child: Text(
            'Page $_currentPage of $_totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: _currentPage < _totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                  _loadRequests();
                }
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _SupportRequestDetailsDialog extends StatefulWidget {
  final SupportRequest request;
  final SupportRequestService service;

  const _SupportRequestDetailsDialog({
    required this.request,
    required this.service,
  });

  @override
  State<_SupportRequestDetailsDialog> createState() =>
      _SupportRequestDetailsDialogState();
}

class _SupportRequestDetailsDialogState
    extends State<_SupportRequestDetailsDialog> {
  bool _isSaving = false;

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(local.day)}.${two(local.month)}.${local.year}. '
        '${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _markInProgress() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await widget.service.setInProgress(widget.request.id);

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request marked as in progress.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _resolve() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await widget.service.resolve(widget.request.id);

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request closed successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFA67C52).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFA67C52),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Support Request',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: _isSaving
                ? null
                : () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(
                icon: Icons.person_outline_rounded,
                label: 'Customer',
                value: request.fullName,
              ),
              const SizedBox(height: 12),
              _infoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: request.email,
              ),
              const SizedBox(height: 12),
              _infoRow(
                icon: Icons.schedule_rounded,
                label: 'Created',
                value: _formatDate(request.createdAt),
              ),
              const SizedBox(height: 20),
              const Text(
                'Subject',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                request.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Message',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F6F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8E3DD),
                  ),
                ),
                child: Text(
                  request.message,
                  style: const TextStyle(
                    height: 1.5,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    request.statusName,
                    style: const TextStyle(
                      color: Color(0xFFA67C52),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(context),
          child: const Text('Close'),
        ),

        if (request.isOpen)
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _markInProgress,
            icon: const Icon(Icons.pending_actions_rounded),
            label: const Text('Mark In Progress'),
          ),

        if (!request.isClosed)
          FilledButton.icon(
            onPressed: _isSaving ? null : _resolve,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFA67C52),
              foregroundColor: Colors.white,
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Resolve'),
          ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xFFA67C52),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}