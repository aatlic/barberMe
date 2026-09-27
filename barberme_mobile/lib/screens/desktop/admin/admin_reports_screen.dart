import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/report.dart';
import '../../../models/user.dart';
import '../../../services/report_service.dart';
import '../../../services/user_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() =>
      _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  static const int _barberRoleId = 2;

  final ReportService _reportService = ReportService();
  final UserService _userService = UserService();

  late TabController _tabController;

  DateTime _dateFrom = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  DateTime _dateTo = DateTime.now();

  List<User> _barbers = [];
  int? _selectedBarberId;

  Report? _report;
  BarberPerformanceReport? _performanceReport;

  bool _isLoadingBarbers = true;
  bool _isLoadingReport = false;
  bool _isDownloading = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _errorMessage = null;
        });
      }
    });

    _loadBarbers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBarbers() async {
    try {
      final response = await _userService.getUsers(
        roleId: _barberRoleId,
        isActive: true,
        page: 1,
        pageSize: 100,
      );

      if (!mounted) return;

      setState(() {
        _barbers = response.items;
        _isLoadingBarbers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingBarbers = false;
        _errorMessage = _cleanError(e);
      });
    }
  }

  Future<void> _generateReport() async {
    if (_dateFrom.isAfter(_dateTo)) {
      setState(() {
        _errorMessage =
            'Date From cannot be after Date To.';
      });
      return;
    }

    setState(() {
      _isLoadingReport = true;
      _errorMessage = null;
    });

    try {
      if (_tabController.index == 0) {
        final result = await _reportService.getReport(
          dateFrom: _dateFrom,
          dateTo: _dateTo,
          barberId: _selectedBarberId,
        );

        if (!mounted) return;

        setState(() {
          _report = result;
        });
      } else {
        final result =
            await _reportService.getBarberPerformanceReport(
          dateFrom: _dateFrom,
          dateTo: _dateTo,
          barberId: _selectedBarberId,
        );

        if (!mounted) return;

        setState(() {
          _performanceReport = result;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReport = false;
        });
      }
    }
  }

  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
    });

    try {
      late Uint8List bytes;
      late String defaultFileName;

      if (_tabController.index == 0) {
        bytes = await _reportService.downloadReportPdf(
          dateFrom: _dateFrom,
          dateTo: _dateTo,
          barberId: _selectedBarberId,
        );

        defaultFileName =
            'barber-report-${_fileDate(_dateFrom)}-${_fileDate(_dateTo)}.pdf';
      } else {
        bytes = await _reportService
            .downloadBarberPerformancePdf(
          dateFrom: _dateFrom,
          dateTo: _dateTo,
          barberId: _selectedBarberId,
        );

        final barberPart = _selectedBarberId != null
            ? '-$_selectedBarberId'
            : '-all';

        defaultFileName =
            'barber-performance-${_fileDate(_dateFrom)}-${_fileDate(_dateTo)}$barberPart.pdf';
      }

      final outputUri = await FilePicker.saveFile(
        dialogTitle: 'Save report',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
      );

      if (outputUri == null) {
        return;
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report downloaded successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _selectDate({
    required bool isFrom,
  }) async {
    final initialDate = isFrom ? _dateFrom : _dateTo;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (selectedDate == null) return;

    setState(() {
      if (isFrom) {
        _dateFrom = selectedDate;
      } else {
        _dateTo = selectedDate;
      }

      _report = null;
      _performanceReport = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                28,
                0,
                28,
                28,
              ),
              child: Column(
                children: [
                  _buildTabs(),
                  const SizedBox(height: 20),
                  _buildFilters(),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    _buildError(),
                  if (_errorMessage != null)
                    const SizedBox(height: 16),
                  Expanded(
                    child: _buildContent(),
                  ),
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
      padding: const EdgeInsets.fromLTRB(
        28,
        28,
        28,
        22,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Generate and review business reports.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) {
          setState(() {
            _errorMessage = null;
          });
        },
        labelColor: AppTheme.accentColor,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: AppTheme.accentColor,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(Icons.description_outlined),
            text: 'General Report',
          ),
          Tab(
            icon: Icon(Icons.bar_chart_outlined),
            text: 'Barber Performance',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildDateField(
              label: 'Date From',
              date: _dateFrom,
              onTap: () => _selectDate(
                isFrom: true,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDateField(
              label: 'Date To',
              date: _dateTo,
              onTap: () => _selectDate(
                isFrom: false,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _buildBarberField(),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoadingReport
                  ? null
                  : _generateReport,
              icon: _isLoadingReport
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.visibility_outlined),
              label: const Text('Preview Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 10),
                Text(
                  _displayDate(date),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Barber',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int?>(
          value: _selectedBarberId,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('All barbers'),
            ),
            ..._barbers.map(
              (barber) => DropdownMenuItem<int?>(
                value: barber.id,
                child: Text(
                  '${barber.firstName} ${barber.lastName}',
                ),
              ),
            ),
          ],
          onChanged: _isLoadingBarbers
              ? null
              : (value) {
                  setState(() {
                    _selectedBarberId = value;
                    _report = null;
                    _performanceReport = null;
                  });
                },
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoadingReport) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_tabController.index == 0) {
      if (_report == null) {
        return _buildEmptyPreview();
      }

      return _buildGeneralReport(_report!);
    }

    if (_performanceReport == null) {
      return _buildEmptyPreview();
    }

    return _buildPerformanceReport(
      _performanceReport!,
    );
  }

  Widget _buildEmptyPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Report Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select filters and click Preview Report.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralReport(Report report) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildReportToolbar(
            title: 'Appointment Report',
            subtitle:
                '${_displayDate(report.dateFrom)} - ${_displayDate(report.dateTo)} • ${report.barberName}',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Appointments',
                  report.totalAppointments.toString(),
                  Icons.calendar_month_outlined,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryCard(
                  'Completed',
                  report.completedAppointments
                      .toString(),
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryCard(
                  'Cancelled',
                  report.cancelledAppointments
                      .toString(),
                  Icons.cancel_outlined,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryCard(
                  'Clients',
                  report.uniqueClients.toString(),
                  Icons.people_outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryCard(
                  'Revenue',
                  '${_money(report.totalRevenue)} BAM',
                  Icons.payments_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildServicesTable(report.services),
          const SizedBox(height: 16),
          _buildAppointmentsTable(
            report.appointments,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceReport(
    BarberPerformanceReport report,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildReportToolbar(
            title: 'Barber Performance Report',
            subtitle:
                '${_displayDate(report.dateFrom)} - ${_displayDate(report.dateTo)}',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Barbers',
                  report.barbers.length.toString(),
                  Icons.content_cut,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryCard(
                  'Completed',
                  report.totalCompletedAppointments
                      .toString(),
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryCard(
                  'Clients',
                  report.totalUniqueClients
                      .toString(),
                  Icons.people_outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryCard(
                  'Revenue',
                  '${_money(report.totalRevenue)} BAM',
                  Icons.payments_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPerformanceTable(report.barbers),
        ],
      ),
    );
  }

  Widget _buildReportToolbar({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed:
                _isDownloading ? null : _downloadPdf,
            icon: _isDownloading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.download_outlined,
                  ),
            label: const Text('Download PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentColor,
              side: const BorderSide(
                color: AppTheme.accentColor,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTable(
    List<ReportServiceItem> services,
  ) {
    return _tableContainer(
      title: 'Services',
      child: services.isEmpty
          ? _emptyTable('No service data available.')
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Service')),
                  DataColumn(
                    label: Text('Appointments'),
                  ),
                  DataColumn(
                    label: Text('Unit Price'),
                  ),
                  DataColumn(
                    label: Text('Revenue'),
                  ),
                ],
                rows: services
                    .map(
                      (service) => DataRow(
                        cells: [
                          DataCell(
                            Text(service.serviceName),
                          ),
                          DataCell(
                            Text(
                              service.appointmentCount
                                  .toString(),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${_money(service.unitPrice)} BAM',
                            ),
                          ),
                          DataCell(
                            Text(
                              '${_money(service.totalRevenue)} BAM',
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  Widget _buildAppointmentsTable(
    List<ReportAppointmentItem> appointments,
  ) {
    return _tableContainer(
      title: 'Appointments',
      child: appointments.isEmpty
          ? _emptyTable('No appointments found.')
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Client')),
                  DataColumn(label: Text('Barber')),
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Paid')),
                  DataColumn(label: Text('Price')),
                ],
                rows: appointments
                    .map(
                      (appointment) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              appointment.clientName,
                            ),
                          ),
                          DataCell(
                            Text(
                              appointment.barberName,
                            ),
                          ),
                          DataCell(
                            Text(
                              appointment.serviceName,
                            ),
                          ),
                          DataCell(
                            Text(
                              _displayDateTime(
                                appointment
                                    .startDateTime,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(appointment.status),
                          ),
                          DataCell(
                            Text(
                              appointment.isPaid
                                  ? 'Yes'
                                  : 'No',
                            ),
                          ),
                          DataCell(
                            Text(
                              '${_money(appointment.finalPrice)} BAM',
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  Widget _buildPerformanceTable(
    List<BarberPerformanceItem> barbers,
  ) {
    return _tableContainer(
      title: 'Barber Performance',
      child: barbers.isEmpty
          ? _emptyTable(
              'No completed appointments were found for the selected period.',
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Barber')),
                  DataColumn(
                    label: Text('Appointments'),
                  ),
                  DataColumn(label: Text('Clients')),
                  DataColumn(label: Text('Revenue')),
                  DataColumn(label: Text('Rating')),
                  DataColumn(
                    label: Text('Top Service'),
                  ),
                ],
                rows: barbers
                    .map(
                      (barber) => DataRow(
                        cells: [
                          DataCell(
                            Text(barber.barberName),
                          ),
                          DataCell(
                            Text(
                              barber.completedAppointments
                                  .toString(),
                            ),
                          ),
                          DataCell(
                            Text(
                              barber.uniqueClients
                                  .toString(),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${_money(barber.totalRevenue)} BAM',
                            ),
                          ),
                          DataCell(
                            Text(
                              barber.averageRating
                                  .toStringAsFixed(2),
                            ),
                          ),
                          DataCell(
                            Text(
                              barber.mostPopularService,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  Widget _tableContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _emptyTable(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month =
        date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  String _displayDateTime(DateTime date) {
    final hour =
        date.hour.toString().padLeft(2, '0');
    final minute =
        date.minute.toString().padLeft(2, '0');

    return '${_displayDate(date)} $hour:$minute';
  }

  String _fileDate(DateTime date) {
    final month =
        date.month.toString().padLeft(2, '0');
    final day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}$month$day';
  }

  String _money(double value) {
    return value.toStringAsFixed(2);
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}