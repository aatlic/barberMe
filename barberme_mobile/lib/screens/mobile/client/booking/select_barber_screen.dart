import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/user.dart';
import '../../../../services/user_service.dart';
import '../../../../core/config/api_config.dart';
import 'select_service_screen.dart';

class SelectBarberScreen extends StatefulWidget {
  const SelectBarberScreen({super.key});

  @override
  State<SelectBarberScreen> createState() =>
      _SelectBarberScreenState();
}

class _SelectBarberScreenState
    extends State<SelectBarberScreen> {
  final UserService _userService = UserService();

  List<User> _barbers = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBarbers();
  }

  Future<void> _loadBarbers() async {
    try {
      final barbers = await _userService.getBarbers();

      if (!mounted) return;

      setState(() {
        _barbers = barbers;
        _isLoading = false;
        _errorMessage = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select barber',
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
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  _loadBarbers();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_barbers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No barbers are currently available.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBarbers,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _barbers.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final barber = _barbers[index];

          return _BarberCard(
            barber: barber,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SelectServiceScreen(
                    barber: barber,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BarberCard extends StatelessWidget {
  final User barber;
  final VoidCallback onTap;

  const _BarberCard({
    required this.barber,
    required this.onTap,
  });

  String? _getProfileImageUrl() {
    final path = barber.profileImagePath;

    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final normalizedPath = path.replaceAll('\\', '/');

    if (normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://')) {
      return normalizedPath;
    }

    final cleanPath = normalizedPath.startsWith('/')
        ? normalizedPath
        : '/$normalizedPath';

    return '${ApiConfig.baseUrl}$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final fullName =
        '${barber.firstName} ${barber.lastName}'.trim();

    final profileImageUrl = _getProfileImageUrl();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    AppTheme.accentColor.withValues(
                  alpha: 0.12,
                ),
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(
                        Icons.person_outline,
                        color: AppTheme.accentColor,
                        size: 30,
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (barber.barberLevel != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        barber.barberLevel!.name,
                        style: const TextStyle(
                          color:
                              AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}