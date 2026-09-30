class News {
  final int id;
  final String title;
  final String content;
  final String? image;
  final bool isActive;
  final DateTime createdAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    required this.isActive,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      image: json['image']?.toString(),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['createdAt'].toString(),
      ),
    );
  }
}