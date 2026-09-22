import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/shop_working_hours.dart';
import '../../../services/shop_service.dart';

class AdminCompanyInformationScreen extends StatefulWidget {
  const AdminCompanyInformationScreen({super.key});

  @override
  State<AdminCompanyInformationScreen> createState() =>
      _AdminCompanyInformationScreenState();
}

class _AdminCompanyInformationScreenState
    extends State<AdminCompanyInformationScreen>
    with SingleTickerProviderStateMixin {
  final ShopService _shopService = ShopService();

  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoadingSettings = true;
  bool _isSavingSettings = false;
  String? _settingsError;

  bool _isLoadingHours = true;
  String? _hoursError;

  List<ShopWorkingHours> _workingHours = [];

  final Map<int, TimeOfDay> _startTimes = {};
  final Map<int, TimeOfDay> _endTimes = {};
  final Map<int, bool> _workingDays = {};

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _loadSettings();
    _loadWorkingHours();
  }

  @override
  void dispose() {
    _tabController.dispose();

    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // COMPANY INFORMATION
  // ------------------------------------------------------------

  Future<void> _loadSettings() async {
    setState(() {
      _isLoadingSettings = true;
      _settingsError = null;
    });

    try {
      final settings =
          await _shopService.getShopSettings();

      if (!mounted) return;

      _nameController.text = settings.name;
      _addressController.text = settings.address;
      _phoneController.text = settings.phoneNumber;
      _emailController.text = settings.email;
      _descriptionController.text =
          settings.description ?? '';

      setState(() {
        _isLoadingSettings = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSettings = false;
        _settingsError = _cleanError(e);
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSavingSettings = true;
    });

    try {
      final updated =
          await _shopService.updateShopSettings(
        name: _nameController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        description: _descriptionController.text,
      );

      if (!mounted) return;

      _nameController.text = updated.name;
      _addressController.text = updated.address;
      _phoneController.text = updated.phoneNumber;
      _emailController.text = updated.email;
      _descriptionController.text =
          updated.description ?? '';

      setState(() {
        _isSavingSettings = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Company information updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSavingSettings = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(e)),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // WORKING HOURS
  // ------------------------------------------------------------

  Future<void> _loadWorkingHours() async {
    setState(() {
      _isLoadingHours = true;
      _hoursError = null;
    });

    try {
      final result =
          await _shopService.getWorkingHours();

      if (!mounted) return;

      _workingHours = result;

      _startTimes.clear();
      _endTimes.clear();
      _workingDays.clear();

      for (final item in result) {
        _startTimes[item.id] =
            _parseTime(item.startTime);

        _endTimes[item.id] =
            _parseTime(item.endTime);

        _workingDays[item.id] =
            item.isWorking;
      }

      setState(() {
        _isLoadingHours = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingHours = false;
        _hoursError = _cleanError(e);
      });
    }
  }

  TimeOfDay _parseTime(String value) {
    try {
      final parts = value.split(':');

      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return const TimeOfDay(
        hour: 9,
        minute: 0,
      );
    }
  }

  String _formatTimeForApi(
    TimeOfDay time,
  ) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  String _formatTimeForUi(
    TimeOfDay time,
  ) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _selectStartTime(
    ShopWorkingHours item,
  ) async {
    final current =
        _startTimes[item.id] ??
            const TimeOfDay(
              hour: 9,
              minute: 0,
            );

    final selected = await showTimePicker(
      context: context,
      initialTime: current,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _startTimes[item.id] = selected;
    });
  }

  Future<void> _selectEndTime(
    ShopWorkingHours item,
  ) async {
    final current =
        _endTimes[item.id] ??
            const TimeOfDay(
              hour: 17,
              minute: 0,
            );

    final selected = await showTimePicker(
      context: context,
      initialTime: current,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _endTimes[item.id] = selected;
    });
  }

  bool _isStartBeforeEnd(
    TimeOfDay start,
    TimeOfDay end,
  ) {
    final startMinutes =
        start.hour * 60 + start.minute;

    final endMinutes =
        end.hour * 60 + end.minute;

    return startMinutes < endMinutes;
  }

  Future<void> _saveWorkingHour(
    ShopWorkingHours item,
  ) async {
    final start =
        _startTimes[item.id] ??
            _parseTime(item.startTime);

    final end =
        _endTimes[item.id] ??
            _parseTime(item.endTime);

    final isWorking =
        _workingDays[item.id] ??
            item.isWorking;

    if (isWorking &&
        !_isStartBeforeEnd(start, end)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Start time must be earlier than end time.',
          ),
        ),
      );

      return;
    }

    try {
      final updated =
          await _shopService.updateWorkingHours(
        id: item.id,
        dayOfWeek: item.dayOfWeek,
        startTime:
            _formatTimeForApi(start),
        endTime:
            _formatTimeForApi(end),
        isWorking: isWorking,
      );

      if (!mounted) return;

      final index =
          _workingHours.indexWhere(
        (x) => x.id == item.id,
      );

      if (index != -1) {
        setState(() {
          _workingHours[index] = updated;

          _startTimes[item.id] =
              _parseTime(updated.startTime);

          _endTimes[item.id] =
              _parseTime(updated.endTime);

          _workingDays[item.id] =
              updated.isWorking;
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${_dayName(item.dayOfWeek)} working hours updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _cleanError(e),
          ),
        ),
      );
    }
  }

  String _dayName(int dayOfWeek) {
    switch (dayOfWeek) {
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
      case 0:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  // ------------------------------------------------------------
  // SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Company Information',
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor:
                    AppTheme.accentColor,
                unselectedLabelColor:
                    Colors.grey.shade600,
                indicatorColor:
                    AppTheme.accentColor,
                indicatorWeight: 3,
                labelStyle:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(
                      Icons
                          .business_outlined,
                    ),
                    text:
                        'Company Information',
                  ),
                  Tab(
                    icon: Icon(
                      Icons
                          .schedule_outlined,
                    ),
                    text:
                        'Working Hours',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCompanyTab(),
                _buildWorkingHoursTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // COMPANY TAB
  // ------------------------------------------------------------

  Widget _buildCompanyTab() {
    if (_isLoadingSettings) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_settingsError != null) {
      return _buildError(
        message: _settingsError!,
        onRetry: _loadSettings,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1000,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Company Information',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage general information about your barber shop.',
                style: TextStyle(
                  fontSize: 15,
                  color:
                      Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              _buildCompanyForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFE5E1DC),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration:
                      BoxDecoration(
                    color: AppTheme
                        .accentColor
                        .withValues(
                          alpha: 0.12,
                        ),
                    borderRadius:
                        BorderRadius
                            .circular(12),
                  ),
                  child: const Icon(
                    Icons
                        .storefront_outlined,
                    color: AppTheme
                        .accentColor,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Shop Details',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Information displayed throughout the application.',
                        style: TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            _buildLabel('Shop Name'),
            const SizedBox(height: 8),

            TextFormField(
              controller:
                  _nameController,
              decoration:
                  const InputDecoration(
                hintText:
                    'Enter shop name',
                prefixIcon: Icon(
                  Icons.store_outlined,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Shop name is required.';
                }

                if (value
                        .trim()
                        .length >
                    100) {
                  return 'Shop name cannot exceed 100 characters.';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildLabel('Address'),
            const SizedBox(height: 8),

            TextFormField(
              controller:
                  _addressController,
              decoration:
                  const InputDecoration(
                hintText:
                    'Enter shop address',
                prefixIcon: Icon(
                  Icons
                      .location_on_outlined,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Address is required.';
                }

                if (value
                        .trim()
                        .length >
                    200) {
                  return 'Address cannot exceed 200 characters.';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            LayoutBuilder(
              builder:
                  (context, constraints) {
                final isWide =
                    constraints.maxWidth >=
                        650;

                if (!isWide) {
                  return Column(
                    children: [
                      _buildPhoneField(),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildEmailField(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Expanded(
                      child:
                          _buildPhoneField(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child:
                          _buildEmailField(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            _buildLabel('Description'),
            const SizedBox(height: 8),

            TextFormField(
              controller:
                  _descriptionController,
              minLines: 4,
              maxLines: 6,
              decoration:
                  const InputDecoration(
                hintText:
                    'Enter a short description of the barber shop',
              ),
              validator: (value) {
                if (value != null &&
                    value
                            .trim()
                            .length >
                        500) {
                  return 'Description cannot exceed 500 characters.';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      _isSavingSettings
                          ? null
                          : _loadSettings,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label:
                      const Text('Reset'),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 46,
                  child:
                      FilledButton.icon(
                    onPressed:
                        _isSavingSettings
                            ? null
                            : _saveSettings,
                    icon:
                        _isSavingSettings
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .save_outlined,
                              ),
                    label: Text(
                      _isSavingSettings
                          ? 'Saving...'
                          : 'Save Changes',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildLabel('Phone Number'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration:
              const InputDecoration(
            hintText:
                'Enter phone number',
            prefixIcon: Icon(
              Icons.phone_outlined,
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Phone number is required.';
            }

            if (value.trim().length >
                30) {
              return 'Phone number cannot exceed 30 characters.';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildLabel('Email'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration:
              const InputDecoration(
            hintText:
                'Enter email address',
            prefixIcon: Icon(
              Icons.email_outlined,
            ),
          ),
          validator: (value) {
            final email =
                value?.trim() ?? '';

            if (email.isEmpty) {
              return 'Email is required.';
            }

            final emailRegex = RegExp(
              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
            );

            if (!emailRegex
                .hasMatch(email)) {
              return 'Enter a valid email address.';
            }

            if (email.length > 100) {
              return 'Email cannot exceed 100 characters.';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // WORKING HOURS TAB
  // ------------------------------------------------------------

  Widget _buildWorkingHoursTab() {
    if (_isLoadingHours) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_hoursError != null) {
      return _buildError(
        message: _hoursError!,
        onRetry: _loadWorkingHours,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1000,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage the general opening hours of the barber shop.',
                style: TextStyle(
                  fontSize: 15,
                  color:
                      Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              if (_workingHours.isEmpty)
                _buildEmptyHours()
              else
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    22,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(16),
                    border: Border.all(
                      color: const Color(
                        0xFFE5E1DC,
                      ),
                    ),
                  ),
                  child: Column(
                    children:
                        _workingHours
                            .map(
                              _buildDayRow,
                            )
                            .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(
    ShopWorkingHours item,
  ) {
    final isWorking =
        _workingDays[item.id] ??
            item.isWorking;

    final start =
        _startTimes[item.id] ??
            _parseTime(item.startTime);

    final end =
        _endTimes[item.id] ??
            _parseTime(item.endTime);

    final isLast =
        _workingHours.last.id ==
            item.id;

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 125,
                child: Text(
                  _dayName(
                    item.dayOfWeek,
                  ),
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(
                width: 115,
                child: Row(
                  children: [
                    Switch(
                      value: isWorking,
                      activeThumbColor:
                          AppTheme
                              .accentColor,
                      onChanged: (value) {
                        setState(() {
                          _workingDays[
                                  item.id] =
                              value;
                        });
                      },
                    ),
                    Text(
                      isWorking
                          ? 'Open'
                          : 'Closed',
                      style: TextStyle(
                        color: isWorking
                            ? Colors
                                .green
                                .shade700
                            : Colors
                                .grey
                                .shade600,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child:
                          _buildTimeButton(
                        label: 'Opens',
                        time: start,
                        enabled:
                            isWorking,
                        onPressed: () =>
                            _selectStartTime(
                          item,
                        ),
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        'to',
                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ),

                    Expanded(
                      child:
                          _buildTimeButton(
                        label: 'Closes',
                        time: end,
                        enabled:
                            isWorking,
                        onPressed: () =>
                            _selectEndTime(
                          item,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              SizedBox(
                height: 42,
                child:
                    FilledButton.icon(
                  onPressed: () =>
                      _saveWorkingHour(
                    item,
                  ),
                  icon: const Icon(
                    Icons.save_outlined,
                    size: 18,
                  ),
                  label:
                      const Text('Save'),
                ),
              ),
            ],
          ),
        ),

        if (!isLast)
          const Divider(height: 1),
      ],
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay time,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: enabled
          ? onPressed
          : null,
      borderRadius:
          BorderRadius.circular(10),
      child: Container(
        height: 50,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white
              : Colors.grey.shade100,
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: const Color(
              0xFFE5E1DC,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 19,
              color: enabled
                  ? AppTheme.accentColor
                  : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _formatTimeForUi(
                      time,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHours() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFE5E1DC),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 14),
          Text(
            'No working hours found.',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}