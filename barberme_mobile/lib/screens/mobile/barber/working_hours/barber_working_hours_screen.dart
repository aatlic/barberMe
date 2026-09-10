import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/working_hours.dart';
import '../../../../services/working_hours_service.dart';

class BarberWorkingHoursScreen extends StatefulWidget {
  const BarberWorkingHoursScreen({super.key});

  @override
  State<BarberWorkingHoursScreen> createState() =>
      _BarberWorkingHoursScreenState();
}

class _BarberWorkingHoursScreenState
    extends State<BarberWorkingHoursScreen> {
  final WorkingHoursService _workingHoursService =
      WorkingHoursService();

  bool _isLoading = true;
  String? _errorMessage;

  List<WorkingHours> _workingHours = [];

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  Future<void> _loadWorkingHours() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _workingHoursService.getMyWorkingHours();

      if (!mounted) return;

      setState(() {
        _workingHours = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e
            .toString()
            .replaceFirst('Exception: ', '');

        _isLoading = false;
      });
    }
  }

  String _formatTime(String value) {
    if (value.isEmpty) return '';

    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    return '${parts[0]}:${parts[1]}';
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return 'Unknown day';
    }
  }

  List<WorkingHours> get _sortedWorkingHours {
    final list =
        List<WorkingHours>.from(_workingHours);

    list.sort(
      (a, b) => a.dayOfWeek.compareTo(b.dayOfWeek),
    );

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My working hours',
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
              const SizedBox(
                height: 16,
              ),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton(
                onPressed: _loadWorkingHours,
                child: const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_workingHours.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadWorkingHours,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(
              height: 120,
            ),
            Icon(
              Icons.schedule_outlined,
              size: 52,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'No working hours have been configured yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkingHours,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Weekly schedule',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          const Text(
            'Your working hours are managed by the administrator.',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ..._sortedWorkingHours.map(
            _buildWorkingHoursCard,
          ),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursCard(
    WorkingHours workingHours,
  ) {
    final dayName =
        workingHours.dayName.trim().isNotEmpty
            ? workingHours.dayName
            : _getDayName(workingHours.dayOfWeek);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons.schedule_outlined,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    workingHours.isWorking
                        ? '${_formatTime(workingHours.startTime)} - ${_formatTime(workingHours.endTime)}'
                        : 'Not working',
                    style: TextStyle(
                      color: workingHours.isWorking
                          ? AppTheme.textSecondaryColor
                          : Colors.red.shade700,
                      fontWeight:
                          workingHours.isWorking
                              ? FontWeight.normal
                              : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              workingHours.isWorking
                  ? Icons.check_circle_outline
                  : Icons.remove_circle_outline,
              color: workingHours.isWorking
                  ? AppTheme.accentColor
                  : Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }
}