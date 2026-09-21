import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'admin_services_screen.dart';

class AdminCodebooksScreen extends StatelessWidget {
  const AdminCodebooksScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1250,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Codebooks',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage salon services, barber levels and company information.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    int crossAxisCount = 3;

                    if (constraints.maxWidth < 850) {
                      crossAxisCount = 2;
                    }

                    if (constraints.maxWidth < 550) {
                      crossAxisCount = 1;
                    }

                    const spacing = 18.0;

                    final itemWidth =
                        (constraints.maxWidth -
                                spacing *
                                    (crossAxisCount -
                                        1)) /
                            crossAxisCount;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _CodebookCard(
                            title: 'Services',
                            subtitle:
                                'Manage services, prices and durations.',
                            icon: Icons
                                .design_services_outlined,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminServicesScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _CodebookCard(
                            title: 'Barber Levels',
                            subtitle:
                                'Manage employee levels such as Junior, Senior and Master.',
                            icon:
                                Icons.workspace_premium_outlined,
                            onTap: () {
                              // Later:
                              // Barber Levels screen.
                            },
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _CodebookCard(
                            title:
                                'Company Information',
                            subtitle:
                                'Manage salon and company information.',
                            icon:
                                Icons.business_outlined,
                            onTap: () {
                              // Later:
                              // Company Information screen.
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CodebookCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CodebookCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 180,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E1DC),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor
                      .withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color:
                      AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color:
                      AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text(
                    'Manage',
                    style: TextStyle(
                      color:
                          AppTheme.accentColor,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward,
                    size: 17,
                    color:
                        AppTheme.accentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}