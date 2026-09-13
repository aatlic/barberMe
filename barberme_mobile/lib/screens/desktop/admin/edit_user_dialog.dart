import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';

class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog({
    super.key,
    required this.user,
  });

  @override
  State<EditUserDialog> createState() =>
      _EditUserDialogState();
}

class _EditUserDialogState
    extends State<EditUserDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final UserService _userService = UserService();

  late final TextEditingController
      _firstNameController;

  late final TextEditingController
      _lastNameController;

  late final TextEditingController
      _emailController;

  late final TextEditingController
      _phoneController;

  int? _selectedBarberLevelId;

  late bool _isActive;

  bool _isSaving = false;

  bool get _isBarber =>
      widget.user.role.name == 'Barber';

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(
      text: widget.user.firstName,
    );

    _lastNameController =
        TextEditingController(
      text: widget.user.lastName,
    );

    _emailController =
        TextEditingController(
      text: widget.user.email,
    );

    _phoneController =
        TextEditingController(
      text: widget.user.phoneNumber,
    );

    _selectedBarberLevelId =
      widget.user.barberLevel?.id;

    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isBarber &&
        _selectedBarberLevelId == null) {
      _showMessage(
        'Please select a barber level.',
        isError: true,
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _userService.updateUser(
        userId: widget.user.id,
        firstName:
            _firstNameController.text.trim(),
        lastName:
            _lastNameController.text.trim(),
        email:
            _emailController.text.trim(),
        phoneNumber:
            _phoneController.text.trim(),
        barberLevelId:
            _isBarber
                ? _selectedBarberLevelId
                : null,
        isActive: _isActive,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
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
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 30,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: SizedBox(
        width: 620,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxHeight: 720,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child:
                    SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                    28,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                      children: [
                        _buildReadOnlyInfo(),

                        const SizedBox(
                          height: 22,
                        ),

                        _buildNameFields(),

                        const SizedBox(
                          height: 18,
                        ),

                        _buildEmailField(),

                        const SizedBox(
                          height: 18,
                        ),

                        _buildPhoneField(),

                        if (_isBarber) ...[
                          const SizedBox(
                            height: 18,
                          ),
                          _buildBarberLevelField(),
                        ],

                        const SizedBox(
                          height: 20,
                        ),

                        _buildStatus(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 22,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit user',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: const TextStyle(
                    color:
                        Color(0xFFCFCFCF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSaving
                ? null
                : () {
                    Navigator.of(
                      context,
                    ).pop(false);
                  },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF8F6F3),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              const Color(0xFFE5E1DC),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _infoItem(
              label: 'Username',
              value:
                  widget.user.username,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _infoItem(
              label: 'Role',
              value:
                  widget.user.role.name,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color:
                AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller:
                _firstNameController,
            decoration:
                const InputDecoration(
              labelText: 'First name',
            ),
            validator: (value) {
              final text =
                  value?.trim() ?? '';

              if (text.isEmpty) {
                return 'First name is required.';
              }

              if (text.length < 2 ||
                  text.length > 50) {
                return 'Use 2-50 characters.';
              }

              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller:
                _lastNameController,
            decoration:
                const InputDecoration(
              labelText: 'Last name',
            ),
            validator: (value) {
              final text =
                  value?.trim() ?? '';

              if (text.isEmpty) {
                return 'Last name is required.';
              }

              if (text.length < 2 ||
                  text.length > 50) {
                return 'Use 2-50 characters.';
              }

              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller:
          _emailController,
      decoration:
          const InputDecoration(
        labelText: 'Email',
        prefixIcon:
            Icon(Icons.email_outlined),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Email is required.';
        }

        if (!text.contains('@') ||
            !text.contains('.')) {
          return 'Please enter a valid email address.';
        }

        if (text.length > 100) {
          return 'Email must not exceed 100 characters.';
        }

        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller:
          _phoneController,
      decoration:
          const InputDecoration(
        labelText: 'Phone number',
        prefixIcon:
            Icon(Icons.phone_outlined),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Phone number is required.';
        }

        if (text.length > 30) {
          return 'Phone number must not exceed 30 characters.';
        }

        return null;
      },
    );
  }

  Widget _buildBarberLevelField() {
    return DropdownButtonFormField<int>(
      value: _selectedBarberLevelId,
      decoration:
          const InputDecoration(
        labelText: 'Barber level',
        prefixIcon: Icon(
          Icons.workspace_premium_outlined,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 1,
          child: Text('Junior'),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text('Senior'),
        ),
        DropdownMenuItem(
          value: 3,
          child: Text('Master'),
        ),
      ],
      onChanged: _isSaving
          ? null
          : (value) {
              setState(() {
                _selectedBarberLevelId =
                    value;
              });
            },
      validator: (value) {
        if (_isBarber &&
            value == null) {
          return 'Barber level is required.';
        }

        return null;
      },
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF8F6F3),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              const Color(0xFFE5E1DC),
        ),
      ),
      child: SwitchListTile(
        contentPadding:
            EdgeInsets.zero,
        value: _isActive,
        title: const Text(
          'Active account',
          style: TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _isActive
              ? 'This user can access Barber Me.'
              : 'This user is currently inactive.',
        ),
        onChanged: _isSaving
            ? null
            : (value) {
                setState(() {
                  _isActive = value;
                });
              },
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E1DC),
          ),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:
              Radius.circular(18),
          bottomRight:
              Radius.circular(18),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isSaving
                ? null
                : () {
                    Navigator.of(
                      context,
                    ).pop(false);
                  },
            child:
                const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed:
                _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.save_outlined,
                  ),
            label: Text(
              _isSaving
                  ? 'Saving...'
                  : 'Save changes',
            ),
          ),
        ],
      ),
    );
  }
}