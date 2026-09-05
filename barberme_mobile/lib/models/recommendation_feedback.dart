class RecommendationFeedback {
  final int recommendationId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  RecommendationFeedback({
    required this.recommendationId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory RecommendationFeedback.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecommendationFeedback(
      recommendationId:
          json['recommendationId'] as int,
      rating: json['rating'] as int,
      comment: json['comment']?.toString(),
      createdAt: DateTime.parse(
        json['createdAt'].toString(),
      ),
    );
  }
}