import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final UserService _userService = UserService();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _firstNameController;
  late final TextEditingController
      _lastNameController;
  late final TextEditingController
      _emailController;
  late final TextEditingController
      _phoneController;

  late bool _receiveNewsletter;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.user.firstName,
    );

    _lastNameController = TextEditingController(
      text: widget.user.lastName,
    );

    _emailController = TextEditingController(
      text: widget.user.email,
    );

    _phoneController = TextEditingController(
      text: widget.user.phoneNumber,
    );

    _receiveNewsletter =
        widget.user.receiveNewsletter;
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
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser =
          await _userService.updateCurrentUser(
        firstName:
            _firstNameController.text.trim(),
        lastName:
            _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber:
            _phoneController.text.trim(),
        receiveNewsletter:
            _receiveNewsletter,
      );

      if (!mounted) return;

      Navigator.of(context).pop(updatedUser);
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

  String? _validateName(
    String? value,
    String fieldName,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return '$fieldName is required.';
    }

    if (text.length < 2 ||
        text.length > 50) {
      return '$fieldName must be between 2 and 50 characters.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Email is required.';
    }

    if (text.length > 100) {
      return 'Email must not exceed 100 characters.';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(text)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Phone number is required.';
    }

    if (text.length > 30) {
      return 'Phone number must not exceed 30 characters.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit profile',
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
              const Text(
                'Personal information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Update your personal information below.',
                style: TextStyle(
                  color:
                      AppTheme.textSecondaryColor,
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller:
                    _firstNameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'First name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),
                validator: (value) =>
                    _validateName(
                  value,
                  'First name',
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _lastNameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Last name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),
                validator: (value) =>
                    _validateName(
                  value,
                  'Last name',
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
                validator: _validateEmail,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType:
                    TextInputType.phone,
                textInputAction:
                    TextInputAction.done,
                decoration:
                    const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                ),
                validator: _validatePhone,
                onFieldSubmitted: (_) {
                  _save();
                },
              ),

              const SizedBox(height: 24),

              Card(
                child: SwitchListTile(
                  value: _receiveNewsletter,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _receiveNewsletter =
                                value;
                          });
                        },
                  secondary: const Icon(
                    Icons.mail_outline,
                    color:
                        AppTheme.accentColor,
                  ),
                  title: const Text(
                    'Newsletter',
                  ),
                  subtitle: const Text(
                    'Receive news and updates by email',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed:
                      _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save changes',
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