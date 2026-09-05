import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/recommendation.dart';
import '../../../services/recommendation_service.dart';
import 'booking/select_date_time_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState
    extends State<RecommendationsScreen> {
  final RecommendationService _recommendationService =
      RecommendationService();

  List<Recommendation> _recommendations = [];

  bool _isLoading = true;
  String? _errorMessage;

  int? _updatingRecommendationId;

  @override
  void initState() {
    super.initState();

    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recommendations =
          await _recommendationService.getRecommendations();

      if (!mounted) return;

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRecommendation(
    Recommendation recommendation,
  ) async {
    if (_updatingRecommendationId != null) {
      return;
    }

    setState(() {
      _updatingRecommendationId =
          recommendation.recommendationId;
    });

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SelectDateTimeScreen(
            barberId: recommendation.barberId,
            barberServiceId:
                recommendation.barberServiceId,
            serviceId: recommendation.serviceId,
            barberName: recommendation.barberName,
            serviceName: recommendation.serviceName,
            price: recommendation.price,
            durationMinutes:
                recommendation.durationMinutes,
            recommendationId:
                recommendation.recommendationId,
          ),
        ),
      );

      if (!mounted) return;

      await _loadRecommendations();
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
          _updatingRecommendationId = null;
        });
      }
    }
  }

  Future<void> _rejectRecommendation(
    Recommendation recommendation,
  ) async {
    if (_updatingRecommendationId != null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.thumb_down_alt_outlined,
            size: 42,
          ),
          title: const Text(
            'Not interested?',
          ),
          content: const Text(
            'This recommendation will be marked as not interesting to you.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
              },
              child: const Text(
                'Confirm',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _updatingRecommendationId =
          recommendation.recommendationId;
    });

    try {
      await _recommendationService.setAcceptance(
        recommendationId:
            recommendation.recommendationId,
        wasAccepted: false,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recommendation marked as not interested.',
          ),
        ),
      );

      await _loadRecommendations();
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
          _updatingRecommendationId = null;
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
          'Recommended for you',
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
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                _errorMessage!,
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton(
                onPressed:
                    _loadRecommendations,
                child: const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            _loadRecommendations,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(24),
          children: const [
            SizedBox(
              height: 130,
            ),
            Icon(
              Icons.auto_awesome_outlined,
              size: 60,
              color:
                  AppTheme.textSecondaryColor,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'No recommendations yet.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              'Recommendations will appear as you use Barber Me.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          _loadRecommendations,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          24,
        ),
        itemCount:
            _recommendations.length,
        separatorBuilder: (
          _,
          __,
        ) =>
            const SizedBox(
          height: 14,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          final recommendation =
              _recommendations[index];

          return _RecommendationCard(
            recommendation:
                recommendation,
            isUpdating:
                _updatingRecommendationId ==
                    recommendation
                        .recommendationId,
            onBook: () {
              _acceptRecommendation(
                recommendation,
              );
            },
            onReject: () {
              _rejectRecommendation(
                recommendation,
              );
            },
          );
        },
      ),
    );
  }
}

class _RecommendationCard
    extends StatelessWidget {
  final Recommendation recommendation;
  final bool isUpdating;

  final VoidCallback onBook;
  final VoidCallback onReject;

  const _RecommendationCard({
    required this.recommendation,
    required this.isUpdating,
    required this.onBook,
    required this.onReject,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(
                    color: AppTheme
                        .accentColor
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color:
                        AppTheme.accentColor,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        recommendation
                            .serviceName,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        recommendation
                            .barberName,
                        style:
                            const TextStyle(
                          color: AppTheme
                              .textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon:
                        Icons.schedule_outlined,
                    text:
                        '${recommendation.durationMinutes} min',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon:
                        Icons.payments_outlined,
                    text:
                        '${recommendation.price.toStringAsFixed(2)} BAM',
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                14,
              ),
              decoration:
                  BoxDecoration(
                color: AppTheme
                    .accentColor
                    .withValues(
                  alpha: 0.07,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color:
                        AppTheme.accentColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      recommendation
                          .explanation,
                      style:
                          const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (recommendation.wasAccepted !=
                null) ...[
              const SizedBox(
                height: 14,
              ),
              Row(
                children: [
                  Icon(
                    recommendation.wasAccepted ==
                            true
                        ? Icons
                            .check_circle_outline
                        : Icons
                            .do_not_disturb_alt_outlined,
                    size: 18,
                    color:
                        recommendation.wasAccepted ==
                                true
                            ? Colors.green
                            : AppTheme
                                .textSecondaryColor,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    recommendation.wasAccepted ==
                            true
                        ? 'Interested'
                        : 'Not interested',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w500,
                      color:
                          recommendation.wasAccepted ==
                                  true
                              ? Colors.green
                              : AppTheme
                                  .textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(
              height: 18,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  FilledButton.icon(
                onPressed:
                    isUpdating
                        ? null
                        : onBook,
                icon: isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons
                            .calendar_month_outlined,
                      ),
                label:
                    const Text(
                  'Book this service',
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    isUpdating
                        ? null
                        : onReject,
                icon: const Icon(
                  Icons.thumb_down_alt_outlined,
                ),
                label: const Text(
                  'Not interested',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color:
              AppTheme.accentColor,
        ),
        const SizedBox(
          width: 7,
        ),
        Flexible(
          child: Text(
            text,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}