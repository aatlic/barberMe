import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final AuthService _authService =
      AuthService();

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

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        firstName:
            _firstNameController.text,
        lastName:
            _lastNameController.text,
        username:
            _usernameController.text,
        email:
            _emailController.text,
        phoneNumber:
            _phoneController.text,
        password:
            _passwordController.text,
        confirmPassword:
            _confirmPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully. You can now sign in.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString().replaceFirst(
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

  String? _validateUsername(
    String? value,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Username is required.';
    }

    if (text.length < 3 ||
        text.length > 50) {
      return 'Username must be between 3 and 50 characters.';
    }

    return null;
  }

  String? _validateEmail(
    String? value,
  ) {
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

  String? _validatePhone(
    String? value,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Phone number is required.';
    }

    if (text.length > 30) {
      return 'Phone number must not exceed 30 characters.';
    }

    final phoneRegex = RegExp(
      r'^[0-9+\-\s()]+$',
    );

    if (!phoneRegex.hasMatch(text)) {
      return 'Please enter a valid phone number.';
    }

    return null;
  }

  String? _validatePassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    if (value.length > 100) {
      return 'Password must not exceed 100 characters.';
    }

    return null;
  }

  String? _validateConfirmPassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Password confirmation is required.';
    }

    if (value !=
        _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              const Icon(
                Icons.person_add_outlined,
                size: 56,
                color:
                    AppTheme.accentColor,
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Create your Barber Me account',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Enter your details to start booking appointments.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: AppTheme
                      .textSecondaryColor,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              TextFormField(
                controller:
                    _firstNameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'First name',
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

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _lastNameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Last name',
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

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _usernameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Username',
                  prefixIcon: Icon(
                    Icons
                        .alternate_email,
                  ),
                ),
                validator:
                    _validateUsername,
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _emailController,
                keyboardType:
                    TextInputType
                        .emailAddress,
                textInputAction:
                    TextInputAction.next,
                autofillHints: const [
                  AutofillHints.email,
                ],
                decoration:
                    const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
                validator:
                    _validateEmail,
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _phoneController,
                keyboardType:
                    TextInputType.phone,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Phone number',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                ),
                validator:
                    _validatePhone,
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _passwordController,
                obscureText:
                    !_showPassword,
                textInputAction:
                    TextInputAction.next,
                autofillHints: const [
                  AutofillHints
                      .newPassword,
                ],
                decoration:
                    InputDecoration(
                  labelText:
                      'Password',
                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword =
                            !_showPassword;
                      });
                    },
                    icon: Icon(
                      _showPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),
                  ),
                ),
                validator:
                    _validatePassword,
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _confirmPasswordController,
                obscureText:
                    !_showConfirmPassword,
                textInputAction:
                    TextInputAction.done,
                autofillHints: const [
                  AutofillHints
                      .newPassword,
                ],
                decoration:
                    InputDecoration(
                  labelText:
                      'Confirm password',
                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword =
                            !_showConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),
                  ),
                ),
                validator:
                    _validateConfirmPassword,
                onFieldSubmitted: (_) {
                  _register();
                },
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                'Password must contain at least 6 characters.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme
                      .textSecondaryColor,
                ),
              ),

              if (_errorMessage !=
                  null) ...[
                const SizedBox(
                  height: 16,
                ),
                Text(
                  _errorMessage!,
                  style:
                      const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Text(
                          'Create account',
                        ),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(
                          context,
                        ).pop();
                      },
                child: const Text(
                  'Already have an account? Sign in',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}