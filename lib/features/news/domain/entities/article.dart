// lib/features/news/domain/entities/article.dart

class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String date;  // Add the date field

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.date,  // Initialize the date field
  });

  // Add a factory constructor to convert JSON to Article object
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      date: json['publishedAt'] ?? '', // Get the published date
    );
  }
}
