import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final AuthService _authService =
      AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
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

  Future<void> _submit() async {
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
      final message =
          await _authService.forgotPassword(
        email: _emailController.text,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.mark_email_read_outlined,
              size: 44,
              color: AppTheme.accentColor,
            ),
            title: const Text(
              'Check your email',
            ),
            content: Text(
              message,
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot password',
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
                Icons.lock_reset_outlined,
                size: 56,
                color: AppTheme.accentColor,
              ),

              const SizedBox(
                height: 18,
              ),

              const Text(
                'Reset your password',
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
                'Enter your email address and we will send you a temporary password.',
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
                    _emailController,
                keyboardType:
                    TextInputType
                        .emailAddress,
                textInputAction:
                    TextInputAction.done,
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
                onFieldSubmitted: (_) {
                  _submit();
                },
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
                height: 54,
                child: FilledButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Send reset instructions',
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
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