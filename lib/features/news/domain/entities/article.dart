// lib/features/news/domain/entities/article.dart

class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String date;

  const Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.date,
  });
}
