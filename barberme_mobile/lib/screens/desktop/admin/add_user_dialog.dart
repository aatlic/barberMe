import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/user_service.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() =>
      _AddUserDialogState();
}

class _AddUserDialogState
    extends State<AddUserDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final UserService _userService = UserService();

  final TextEditingController _firstNameController =
      TextEditingController();

  final TextEditingController _lastNameController =
      TextEditingController();

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  int _selectedRoleId = 3;
  int? _selectedBarberLevelId;

  bool _requirePasswordChange = true;
  bool _receiveNewsletter = false;

  bool _isGeneratingPassword = false;
  bool _isSaving = false;

  bool _obscurePassword = false;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _generatePassword() async {
    if (_isGeneratingPassword) {
      return;
    }

    setState(() {
      _isGeneratingPassword = true;
    });

    try {
      final password =
          await _userService.generatePassword();

      if (!mounted) {
        return;
      }

      setState(() {
        _passwordController.text = password;
      });
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
          _isGeneratingPassword = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoleId == 2 &&
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
      await _userService.createUser(
        firstName:
            _firstNameController.text.trim(),
        lastName:
            _lastNameController.text.trim(),
        username:
            _usernameController.text.trim(),
        email:
            _emailController.text.trim(),
        phoneNumber:
            _phoneController.text.trim(),
        password:
            _passwordController.text,
        roleId: _selectedRoleId,
        barberLevelId:
            _selectedRoleId == 2
                ? _selectedBarberLevelId
                : null,
        requirePasswordChange:
            _requirePasswordChange,
        receiveNewsletter:
            _receiveNewsletter,
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
    ScaffoldMessenger.of(context).showSnackBar(
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
        width: 680,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 760,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),

              Flexible(
                child: SingleChildScrollView(
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
                        _buildNameFields(),

                        const SizedBox(
                          height: 18,
                        ),

                        _buildUsernameField(),

                        const SizedBox(
                          height: 18,
                        ),

                        _buildEmailField(),

                        const SizedBox(
                          height: 18,
                        ),

                        _buildPhoneField(),

                        const SizedBox(
                          height: 18,
                        ),

                        _buildRoleField(),

                        if (_selectedRoleId ==
                            2) ...[
                          const SizedBox(
                            height: 18,
                          ),
                          _buildBarberLevelField(),
                        ],

                        const SizedBox(
                          height: 18,
                        ),

                        _buildPasswordField(),

                        const SizedBox(
                          height: 20,
                        ),

                        _buildOptions(),
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
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add_alt_1,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Add user',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Create a new Barber Me user account.',
                  style: TextStyle(
                    color: Color(
                      0xFFCFCFCF,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                _isSaving
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
              prefixIcon: Icon(
                Icons.person_outline,
              ),
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
              prefixIcon: Icon(
                Icons.person_outline,
              ),
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

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(
          Icons.alternate_email,
        ),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Username is required.';
        }

        if (text.length < 3 ||
            text.length > 50) {
          return 'Use 3-50 characters.';
        }

        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType:
          TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(
          Icons.email_outlined,
        ),
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
      controller: _phoneController,
      keyboardType:
          TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone number',
        prefixIcon: Icon(
          Icons.phone_outlined,
        ),
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

  Widget _buildRoleField() {
    return DropdownButtonFormField<int>(
      value: _selectedRoleId,
      decoration: const InputDecoration(
        labelText: 'Role',
        prefixIcon: Icon(
          Icons.admin_panel_settings_outlined,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 1,
          child: Text('Admin'),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text('Barber'),
        ),
        DropdownMenuItem(
          value: 3,
          child: Text('Client'),
        ),
      ],
      onChanged: _isSaving
          ? null
          : (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedRoleId = value;

                if (value != 2) {
                  _selectedBarberLevelId =
                      null;
                }
              });
            },
    );
  }

  Widget _buildBarberLevelField() {
    return DropdownButtonFormField<int>(
      value: _selectedBarberLevelId,
      decoration: const InputDecoration(
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
        if (_selectedRoleId == 2 &&
            value == null) {
          return 'Barber level is required.';
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Initial password',
        prefixIcon: const Icon(
          Icons.lock_outline,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isGeneratingPassword)
              const Padding(
                padding:
                    EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              IconButton(
                tooltip:
                    'Generate password',
                onPressed:
                    _isSaving
                        ? null
                        : _generatePassword,
                icon: const Icon(
                  Icons.refresh,
                ),
              ),

            IconButton(
              tooltip:
                  _obscurePassword
                      ? 'Show password'
                      : 'Hide password',
              onPressed: () {
                setState(() {
                  _obscurePassword =
                      !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons
                        .visibility_off_outlined,
              ),
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return 'Password is required.';
        }

        if (value.length < 8) {
          return 'Password must be at least 8 characters.';
        }

        return null;
      },
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF8F6F3,
        ),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(
            0xFFE5E1DC,
          ),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding:
                EdgeInsets.zero,
            value:
                _requirePasswordChange,
            title: const Text(
              'Require password change',
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'The user must change the initial password after signing in.',
            ),
            onChanged: _isSaving
                ? null
                : (value) {
                    setState(() {
                      _requirePasswordChange =
                          value;
                    });
                  },
          ),

          const Divider(),

          SwitchListTile(
            contentPadding:
                EdgeInsets.zero,
            value:
                _receiveNewsletter,
            title: const Text(
              'Receive newsletter',
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Allow this account to receive newsletter emails.',
            ),
            onChanged: _isSaving
                ? null
                : (value) {
                    setState(() {
                      _receiveNewsletter =
                          value;
                    });
                  },
          ),
        ],
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
            color: Color(
              0xFFE5E1DC,
            ),
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
            child: const Text(
              'Cancel',
            ),
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
                    Icons.person_add_alt_1,
                  ),
            label: Text(
              _isSaving
                  ? 'Creating...'
                  : 'Create user',
            ),
          ),
        ],
      ),
    );
  }
}