import 'dart:io';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

import '../desktop/admin/admin_home_screen.dart';
import '../mobile/barber/barber_home_screen.dart';
import '../mobile/client/client_main_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../mobile/client/change_password_screen.dart';
import 'contact_support_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final AuthService _authService =
      AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
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
      final result = await _authService.login(
        username:
            _usernameController.text.trim(),
        password:
            _passwordController.text,
      );

      if (!mounted) return;

      final user = result.user;
      final roleName = user.role.name;

      if (user.requirePasswordChange) {
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => const ChangePasswordScreen(),
          ),
        );

        if (!mounted) return;

        if (changed != true) {
          return;
        }
      }

      Widget destination;

      if (Platform.isAndroid) {
        if (roleName == 'Client') {
          destination =
              const ClientMainScreen();
        } else if (roleName == 'Barber' ||
            roleName == 'Admin') {
          destination =
              const BarberHomeScreen();
        } else {
          throw Exception(
            'Unsupported user role.',
          );
        }
      } else if (Platform.isWindows) {
        if (roleName == 'Admin') {
          destination =
              const AdminHomeScreen();
        } else {
          throw Exception(
            'This account does not have access to the desktop application.',
          );
        }
      } else {
        throw Exception(
          'Unsupported platform.',
        );
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => destination,
        ),
      );
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
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.content_cut,
                    size: 72,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Barber Me',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Sign in to your account',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  TextFormField(
                    controller:
                        _usernameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your username.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _passwordController,
                    obscureText:
                        _obscurePassword,
                    textInputAction:
                        TextInputAction.done,
                    onFieldSubmitted: (_) {
                      _login();
                    },
                    decoration:
                        InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(
                        Icons.lock_outline,
                      ),
                      border:
                          const OutlineInputBorder(),
                      suffixIcon:
                          IconButton(
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
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please enter your password.';
                      }

                      return null;
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                        child: const Text(
                          'Forgot password?',
                        ),
                      ),

                      const Text(
                        '•',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      TextButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ContactSupportScreen(),
                                  ),
                                );
                              },
                        icon: const Icon(
                          Icons.support_agent_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'Contact support',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

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
                      onPressed:
                          _isLoading
                              ? null
                              : _login,
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
                              'Sign in',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  if (Platform.isAndroid) ...[
                    const SizedBox(
                      height: 14,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                        ),

                        TextButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                      Navigator.of(
                                        context,
                                      ).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                          child:
                              const Text(
                            'Register',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}