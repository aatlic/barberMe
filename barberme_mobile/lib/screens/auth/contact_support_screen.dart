import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/support_service.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({
    super.key,
  });

  @override
  State<ContactSupportScreen> createState() =>
      _ContactSupportScreenState();
}

class _ContactSupportScreenState
    extends State<ContactSupportScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final SupportService _supportService =
      SupportService();

  final TextEditingController _fullNameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _subjectController =
      TextEditingController();

  final TextEditingController _messageController =
      TextEditingController();

  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSending) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      await _supportService.createSupportRequest(
        fullName: _fullNameController.text,
        email: _emailController.text,
        subject: _subjectController.text,
        message: _messageController.text,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline,
              size: 46,
              color: AppTheme.accentColor,
            ),
            title: const Text(
              'Request sent',
            ),
            content: const Text(
              'Your support request has been sent successfully.',
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
          _isSending = false;
        });
      }
    }
  }

  String? _validateFullName(
    String? value,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Full name is required.';
    }

    if (text.length < 2 ||
        text.length > 100) {
      return 'Full name must be between 2 and 100 characters.';
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

  String? _validateSubject(
    String? value,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Subject is required.';
    }

    if (text.length < 3 ||
        text.length > 150) {
      return 'Subject must be between 3 and 150 characters.';
    }

    return null;
  }

  String? _validateMessage(
    String? value,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Message is required.';
    }

    if (text.length < 10 ||
        text.length > 2000) {
      return 'Message must be between 10 and 2000 characters.';
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
          'Contact support',
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
                const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.support_agent_outlined,
                size: 56,
                color: AppTheme.accentColor,
              ),

              const SizedBox(height: 18),

              const Text(
                'How can we help?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Send us a message if you are having trouble accessing your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      AppTheme.textSecondaryColor,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller:
                    _fullNameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),
                validator:
                    _validateFullName,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _emailController,
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
                validator:
                    _validateEmail,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _subjectController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(
                    Icons.subject_outlined,
                  ),
                ),
                validator:
                    _validateSubject,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _messageController,
                maxLength: 2000,
                maxLines: 6,
                textInputAction:
                    TextInputAction.newline,
                decoration:
                    const InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(
                      bottom: 90,
                    ),
                    child: Icon(
                      Icons.message_outlined,
                    ),
                  ),
                ),
                validator:
                    _validateMessage,
              ),

              if (_errorMessage !=
                  null) ...[
                const SizedBox(height: 10),

                Text(
                  _errorMessage!,
                  style:
                      const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed:
                      _isSending
                          ? null
                          : _submit,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_outlined,
                        ),
                  label: Text(
                    _isSending
                        ? 'Sending...'
                        : 'Send request',
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