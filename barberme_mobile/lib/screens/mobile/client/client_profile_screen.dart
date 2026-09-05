import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/api_config.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() =>
      _ClientProfileScreenState();
}

class _ClientProfileScreenState
    extends State<ClientProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  User? _user;

  bool _isLoading = true;
  bool _isUpdatingNewsletter = false;

  String? _errorMessage;

  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _userService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNewsletter(
    bool value,
  ) async {
    final user = _user;

    if (user == null || _isUpdatingNewsletter) {
      return;
    }

    setState(() {
      _isUpdatingNewsletter = true;
    });

    try {
      final updatedUser =
          await _userService.updateCurrentUser(
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        receiveNewsletter: value,
      );

      if (!mounted) return;

      setState(() {
        _user = updatedUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Email notifications enabled.'
                : 'Email notifications disabled.',
          ),
        ),
      );
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
          _isUpdatingNewsletter = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _authService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _pickAndUploadProfileImage() async {
    if (_isUploadingImage) return;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _isUploadingImage = true;
      });

      await _userService.uploadProfileImage(
        filePath: image.path,
      );

      if (!mounted) return;

      await _loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile image updated successfully.',
          ),
        ),
      );
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
          _isUploadingImage = false;
        });
      }
    }
  }

  String? _getProfileImageUrl(User user) {
  final path = user.profileImagePath;

  if (path == null || path.trim().isEmpty) {
    return null;
  }

  if (path.startsWith('http://') ||
      path.startsWith('https://')) {
    return path;
  }

  final normalizedPath = path
      .replaceAll('\\', '/')
      .replaceFirst(RegExp(r'^/+'), '');

  return '${ApiConfig.baseUrl}/$normalizedPath';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadProfile,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _user;

    if (user == null) {
      return const Center(
        child: Text('Profile not available.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(user),

          const SizedBox(height: 20),

          _buildPersonalInformation(user),

          const SizedBox(height: 16),

          _buildPreferences(user),

          const SizedBox(height: 16),

          _buildRewards(user),

          const SizedBox(height: 16),

          _buildAccountActions(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    final profileImageUrl =
        _getProfileImageUrl(user);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor.withValues(
                      alpha: 0.12,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: profileImageUrl == null
                      ? Center(
                          child: Text(
                            _getInitials(user),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        )
                      : Image.network(
                          profileImageUrl,
                          width: 92,
                          height: 92,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            debugPrint(
                              'PROFILE IMAGE URL: $profileImageUrl',
                            );

                            debugPrint(
                              'PROFILE IMAGE ERROR: $error',
                            );

                            return Center(
                              child: Text(
                                _getInitials(user),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: AppTheme.accentColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder:
                          const CircleBorder(),
                      onTap: _isUploadingImage
                          ? null
                          : _pickAndUploadProfileImage,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(8),
                        child: _isUploadingImage
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
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '@${user.username}',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformation(
    User user,
  ) {
    return _SectionCard(
      title: 'Personal information',
      children: [
        _ProfileRow(
          icon: Icons.person_outline,
          label: 'First name',
          value: user.firstName,
        ),
        _ProfileRow(
          icon: Icons.person_outline,
          label: 'Last name',
          value: user.lastName,
        ),
        _ProfileRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        _ProfileRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: user.phoneNumber,
          isLast: true,
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final user = _user;

              if (user == null) return;

              final updatedUser =
                  await Navigator.of(context).push<User>(
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    user: user,
                  ),
                ),
              );

              if (updatedUser == null || !mounted) {
                return;
              }

              setState(() {
                _user = updatedUser;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Profile updated successfully.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.edit_outlined,
            ),
            label: const Text(
              'Edit profile',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferences(
    User user,
  ) {
    return _SectionCard(
      title: 'Preferences',
      children: [
        Row(
          children: [
            const Icon(
              Icons.mail_outline,
              size: 22,
              color: AppTheme.accentColor,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Receive news and updates by email',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            if (_isUpdatingNewsletter)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            else
              Switch(
                value: user.receiveNewsletter,
                onChanged: _updateNewsletter,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewards(
    User user,
  ) {
    return _SectionCard(
      title: 'Rewards',
      children: [
        _ProfileRow(
          icon: Icons.discount_outlined,
          label: 'Current discount',
          value:
              '${user.discountPercent.toStringAsFixed(0)}%',
        ),

        _ProfileRow(
          icon: Icons.warning_amber_outlined,
          label: 'No-show penalty',
          value: user.hasNoShowPenalty
              ? 'Active'
              : 'None',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildAccountActions() {
    return _SectionCard(
      title: 'Account',
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final changed =
                  await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      const ChangePasswordScreen(),
                ),
              );

              if (changed != true || !mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Password changed successfully.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.lock_outline,
            ),
            label: const Text(
              'Change password',
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
            label: const Text(
              'Log out',
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(User user) {
    final first = user.firstName.isNotEmpty
        ? user.firstName[0]
        : '';

    final last = user.lastName.isNotEmpty
        ? user.lastName[0]
        : '';

    return '$first$last'.toUpperCase();
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 21,
              color: AppTheme.accentColor,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color:
                          AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (!isLast) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}