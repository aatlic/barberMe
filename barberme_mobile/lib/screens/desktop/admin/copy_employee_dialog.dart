import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';

class CopyEmployeeDialog extends StatefulWidget {
  const CopyEmployeeDialog({
    super.key,
  });

  @override
  State<CopyEmployeeDialog> createState() =>
      _CopyEmployeeDialogState();
}

class _CopyEmployeeDialogState
    extends State<CopyEmployeeDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final UserService _userService =
      UserService();

  final TextEditingController
      _firstNameController =
      TextEditingController();

  final TextEditingController
      _lastNameController =
      TextEditingController();

  final TextEditingController
      _usernameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _phoneController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  List<User> _barbers = [];

  User? _selectedBarber;

  bool _isLoadingBarbers = true;
  bool _isGeneratingPassword = false;
  bool _isSaving = false;

  bool _requirePasswordChange = true;
  bool _copyServices = true;

  bool _obscurePassword = false;

  String? _loadError;

  @override
  void initState() {
    super.initState();

    _loadBarbers();
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

  Future<void> _loadBarbers() async {
    setState(() {
      _isLoadingBarbers = true;
      _loadError = null;
    });

    try {
      final result =
          await _userService.getBarbers();

      if (!mounted) {
        return;
      }

      final activeBarbers = result
          .where(
            (x) => x.isActive,
          )
          .toList();

      setState(() {
        _barbers = activeBarbers;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError =
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBarbers = false;
        });
      }
    }
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
          await _userService
              .generatePassword();

      if (!mounted) {
        return;
      }

      setState(() {
        _passwordController.text =
            password;
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
          _isGeneratingPassword =
              false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (_selectedBarber == null) {
      _showMessage(
        'Please select an employee to copy.',
        isError: true,
      );

      return;
    }

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _userService.copyEmployee(
        sourceEmployeeId:
            _selectedBarber!.id,
        firstName:
            _firstNameController.text
                .trim(),
        lastName:
            _lastNameController.text
                .trim(),
        username:
            _usernameController.text
                .trim(),
        email:
            _emailController.text
                .trim(),
        phoneNumber:
            _phoneController.text
                .trim(),
        password:
            _passwordController.text,
        requirePasswordChange:
            _requirePasswordChange,
        copyServices:
            _copyServices,
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
            isError
                ? Colors.red
                : null,
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
        width: 650,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxHeight: 760,
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
                        _buildSourceEmployee(),

                        const SizedBox(
                          height: 22,
                        ),

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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 22,
      ),
      decoration:
          const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius:
            BorderRadius.only(
          topLeft:
              Radius.circular(18),
          topRight:
              Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  AppTheme.accentColor,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.copy_outlined,
              color: Colors.white,
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
                  'Copy employee',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Create a new barber based on an existing employee.',
                  style: TextStyle(
                    color:
                        Color(
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

  Widget _buildSourceEmployee() {
    if (_isLoadingBarbers) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading employees...',
            ),
          ],
        ),
      );
    }

    if (_loadError != null) {
      return Container(
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              const Color(
                0xFFFFF2F2,
              ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Failed to load employees.',
              ),
            ),
            TextButton(
              onPressed: _loadBarbers,
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_barbers.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              const Color(
                0xFFF8F6F3,
              ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        child: const Text(
          'There are no active barbers available to copy.',
        ),
      );
    }

    return DropdownButtonFormField<User>(
      initialValue: _selectedBarber,
      decoration:
          const InputDecoration(
        labelText: 'Source employee',
        prefixIcon:
            Icon(
          Icons.content_copy_outlined,
        ),
      ),
      items: _barbers.map(
        (barber) {
          final level =
              barber.barberLevel?.name;

          return DropdownMenuItem<User>(
            value: barber,
            child: Text(
              level == null
                  ? '${barber.firstName} ${barber.lastName}'
                  : '${barber.firstName} ${barber.lastName} - $level',
            ),
          );
        },
      ).toList(),
      onChanged: _isSaving
          ? null
          : (value) {
              setState(() {
                _selectedBarber = value;
              });
            },
      validator: (value) {
        if (value == null) {
          return 'Please select an employee.';
        }

        return null;
      },
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

  Widget _buildUsernameField() {
    return TextFormField(
      controller:
          _usernameController,
      decoration:
          const InputDecoration(
        labelText: 'Username',
        prefixIcon:
            Icon(
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
      controller:
          _emailController,
      keyboardType:
          TextInputType.emailAddress,
      decoration:
          const InputDecoration(
        labelText: 'Email',
        prefixIcon:
            Icon(
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
      controller:
          _phoneController,
      keyboardType:
          TextInputType.phone,
      decoration:
          const InputDecoration(
        labelText:
            'Phone number',
        prefixIcon:
            Icon(
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller:
          _passwordController,
      obscureText:
          _obscurePassword,
      decoration: InputDecoration(
        labelText:
            'Initial password',
        prefixIcon:
            const Icon(
          Icons.lock_outline,
        ),
        suffixIcon: Row(
          mainAxisSize:
              MainAxisSize.min,
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
                icon:
                    const Icon(
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
                    ? Icons
                        .visibility_outlined
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
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(
              0xFFF8F6F3,
            ),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              const Color(
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
                _copyServices,
            title:
                const Text(
              'Copy services',
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            subtitle:
                const Text(
              'Copy services, prices and durations from the selected barber.',
            ),
            onChanged:
                _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _copyServices =
                              value;
                        });
                      },
          ),

          const Divider(),

          SwitchListTile(
            contentPadding:
                EdgeInsets.zero,
            value:
                _requirePasswordChange,
            title:
                const Text(
              'Require password change',
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            subtitle:
                const Text(
              'The new employee must change the initial password after signing in.',
            ),
            onChanged:
                _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _requirePasswordChange =
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
      ),
      decoration:
          const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color:
                Color(
                  0xFFE5E1DC,
                ),
          ),
        ),
        borderRadius:
            BorderRadius.only(
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
            onPressed:
                _isSaving
                    ? null
                    : () {
                        Navigator.of(
                          context,
                        ).pop(false);
                      },
            child:
                const Text(
              'Cancel',
            ),
          ),

          const SizedBox(width: 12),

          FilledButton.icon(
            onPressed:
                _isSaving ||
                        _isLoadingBarbers ||
                        _barbers.isEmpty
                    ? null
                    : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.copy_outlined,
                  ),
            label: Text(
              _isSaving
                  ? 'Copying...'
                  : 'Copy employee',
            ),
          ),
        ],
      ),
    );
  }
}