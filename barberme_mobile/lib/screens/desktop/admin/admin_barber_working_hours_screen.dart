import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/user.dart';
import '../../../models/working_hours.dart';
import '../../../services/working_hours_service.dart';

class AdminBarberWorkingHoursScreen extends StatefulWidget {
  final User barber;

  const AdminBarberWorkingHoursScreen({
    super.key,
    required this.barber,
  });

  @override
  State<AdminBarberWorkingHoursScreen> createState() =>
      _AdminBarberWorkingHoursScreenState();
}

class _AdminBarberWorkingHoursScreenState
    extends State<AdminBarberWorkingHoursScreen> {
  final WorkingHoursService _workingHoursService =
      WorkingHoursService();

  bool _isLoading = true;
  String? _errorMessage;

  List<WorkingHours> _workingHours = [];

  static const List<_DayDefinition> _days = [
    _DayDefinition(1, 'Monday'),
    _DayDefinition(2, 'Tuesday'),
    _DayDefinition(3, 'Wednesday'),
    _DayDefinition(4, 'Thursday'),
    _DayDefinition(5, 'Friday'),
    _DayDefinition(6, 'Saturday'),
    _DayDefinition(0, 'Sunday'),
  ];

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
          await _workingHoursService.getByBarber(
        widget.barber.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _workingHours = result;
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

  List<WorkingHours> _getHoursForDay(
    int dayOfWeek,
  ) {
    final result = _workingHours
        .where(
          (item) =>
              item.dayOfWeek == dayOfWeek &&
              item.isWorking,
        )
        .toList();

    result.sort(
      (a, b) => a.startTime.compareTo(
        b.startTime,
      ),
    );

    return result;
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return const TimeOfDay(
        hour: 8,
        minute: 0,
      );
    }

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatApiTime(
    TimeOfDay time,
  ) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  String _formatDisplayTime(
    String value,
  ) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    return '${parts[0]}:${parts[1]}';
  }

  Future<void> _openAddDialog(
    _DayDefinition day,
  ) async {
    final created =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _WorkingPeriodDialog(
        title:
            'Add working period',
        dayName: day.name,
        onSave: ({
          required startTime,
          required endTime,
        }) async {
          await _workingHoursService
              .createWorkingHours(
            barberId: widget.barber.id,
            dayOfWeek: day.value,
            startTime:
                _formatApiTime(startTime),
            endTime:
                _formatApiTime(endTime),
            isWorking: true,
          );
        },
      ),
    );

    if (created == true) {
      await _loadWorkingHours();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Working period added successfully.',
      );
    }
  }

  Future<void> _openEditDialog(
    WorkingHours item,
  ) async {
    final updated =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _WorkingPeriodDialog(
        title:
            'Edit working period',
        dayName: item.dayName,
        initialStartTime:
            _parseTime(item.startTime),
        initialEndTime:
            _parseTime(item.endTime),
        onSave: ({
          required startTime,
          required endTime,
        }) async {
          await _workingHoursService
              .updateWorkingHours(
            id: item.id,
            startTime:
                _formatApiTime(startTime),
            endTime:
                _formatApiTime(endTime),
            isWorking: true,
          );
        },
      ),
    );

    if (updated == true) {
      await _loadWorkingHours();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Working period updated successfully.',
      );
    }
  }

  Future<void> _deletePeriod(
    WorkingHours item,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove working period',
          ),
          content: Text(
            'Remove ${_formatDisplayTime(item.startTime)}'
            ' – '
            '${_formatDisplayTime(item.endTime)} '
            'from ${item.dayName}?',
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
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.red,
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
      await _workingHoursService
          .deleteWorkingHours(
        item.id,
      );

      if (!mounted) {
        return;
      }

      await _loadWorkingHours();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Working period removed successfully.',
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
          'Working Hours',
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
    return Column(
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
          'Manage weekly working periods for this barber.',
          style: TextStyle(
            fontSize: 14,
            color:
                AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
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
                  _loadWorkingHours,
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: _days
            .map(_buildDayCard)
            .toList(),
      ),
    );
  }

  Widget _buildDayCard(
    _DayDefinition day,
  ) {
    final hours =
        _getHoursForDay(day.value);

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFE5E1DC),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  day.name,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color: AppTheme
                        .textPrimaryColor,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  hours.isEmpty
                      ? 'Not working'
                      : '${hours.length} '
                          '${hours.length == 1 ? 'period' : 'periods'}',
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color: AppTheme
                        .textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: hours.isEmpty
                ? _buildEmptyDay()
                : Column(
                    children: hours
                        .map(
                          _buildPeriodRow,
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(width: 24),
          OutlinedButton.icon(
            onPressed: () {
              _openAddDialog(day);
            },
            icon: const Icon(
              Icons.add,
              size: 18,
            ),
            label: const Text(
              'Add period',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF8F7F5),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 19,
            color:
                AppTheme.textSecondaryColor,
          ),
          SizedBox(width: 10),
          Text(
            'No working periods',
            style: TextStyle(
              color:
                  AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(
    WorkingHours item,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF8F7F5),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            size: 19,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: 12),
          Text(
            '${_formatDisplayTime(item.startTime)}'
            '  –  '
            '${_formatDisplayTime(item.endTime)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppTheme.textPrimaryColor,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Edit',
            onPressed: () {
              _openEditDialog(item);
            },
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () {
              _deletePeriod(item);
            },
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDefinition {
  final int value;
  final String name;

  const _DayDefinition(
    this.value,
    this.name,
  );
}

class _WorkingPeriodDialog
    extends StatefulWidget {
  final String title;
  final String dayName;

  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;

  final Future<void> Function({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) onSave;

  const _WorkingPeriodDialog({
    required this.title,
    required this.dayName,
    required this.onSave,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  State<_WorkingPeriodDialog>
      createState() =>
          _WorkingPeriodDialogState();
}

class _WorkingPeriodDialogState
    extends State<_WorkingPeriodDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _startTime =
        widget.initialStartTime ??
            const TimeOfDay(
              hour: 8,
              minute: 0,
            );

    _endTime =
        widget.initialEndTime ??
            const TimeOfDay(
              hour: 16,
              minute: 0,
            );
  }

  Future<void> _selectStartTime() async {
    final result =
        await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (result == null ||
        !mounted) {
      return;
    }

    setState(() {
      _startTime = result;
    });
  }

  Future<void> _selectEndTime() async {
    final result =
        await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (result == null ||
        !mounted) {
      return;
    }

    setState(() {
      _endTime = result;
    });
  }

  int _minutes(
    TimeOfDay time,
  ) {
    return time.hour * 60 +
        time.minute;
  }

  Future<void> _save() async {
    if (_minutes(_startTime) >=
        _minutes(_endTime)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Start time must be before end time.',
          ),
          backgroundColor:
              Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        startTime: _startTime,
        endTime: _endTime,
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
          backgroundColor:
              Colors.red,
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

  String _formatTime(
    TimeOfDay time,
  ) {
    final hour =
        time.hour
            .toString()
            .padLeft(2, '0');

    final minute =
        time.minute
            .toString()
            .padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.dayName,
              style:
                  const TextStyle(
                fontSize: 14,
                color: AppTheme
                    .textSecondaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start time',
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : _selectStartTime,
                icon: const Icon(
                  Icons.schedule,
                ),
                label: Text(
                  _formatTime(
                    _startTime,
                  ),
                ),
                style:
                    OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 16,
                    horizontal: 18,
                  ),
                  alignment:
                      Alignment.centerLeft,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'End time',
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : _selectEndTime,
                icon: const Icon(
                  Icons.schedule,
                ),
                label: Text(
                  _formatTime(
                    _endTime,
                  ),
                ),
                style:
                    OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 16,
                    horizontal: 18,
                  ),
                  alignment:
                      Alignment.centerLeft,
                ),
              ),
            ),
          ],
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