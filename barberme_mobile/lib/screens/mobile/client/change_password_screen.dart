import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/user_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final UserService _userService = UserService();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _oldPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSaving = false;

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _userService.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword:
            _confirmPasswordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
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

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required.';
    }

    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required.';
    }

    if (value.length < 6) {
      return 'New password must be at least 6 characters long.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password confirmation is required.';
    }

    if (value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.lock_outline,
                size: 56,
                color: AppTheme.accentColor,
              ),

              const SizedBox(height: 18),

              const Text(
                'Change your password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your current password and choose a new password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_showOldPassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.password,
                ],
                decoration: InputDecoration(
                  labelText: 'Current password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showOldPassword =
                            !_showOldPassword;
                      });
                    },
                    icon: Icon(
                      _showOldPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: _validateOldPassword,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.newPassword,
                ],
                decoration: InputDecoration(
                  labelText: 'New password',
                  prefixIcon: const Icon(
                    Icons.lock_reset_outlined,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showNewPassword =
                            !_showNewPassword;
                      });
                    },
                    icon: Icon(
                      _showNewPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: _validateNewPassword,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [
                  AutofillHints.newPassword,
                ],
                decoration: InputDecoration(
                  labelText: 'Confirm new password',
                  prefixIcon: const Icon(
                    Icons.lock_reset_outlined,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword =
                            !_showConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: _validateConfirmPassword,
                onFieldSubmitted: (_) {
                  _changePassword();
                },
              ),

              const SizedBox(height: 12),

              const Text(
                'Password must contain at least 6 characters.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryColor,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    alignment: Alignment.center,
                  ),
                  onPressed: _isSaving
                      ? null
                      : _changePassword,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Change password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}