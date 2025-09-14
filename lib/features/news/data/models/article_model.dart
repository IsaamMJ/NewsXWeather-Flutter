import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required String title,
    required String description,
    required String fullContent,
    String scrapedContent = '',
    required String imageUrl,
    required String url,
    required String date,
    bool isContentScraped = false,
  }) : super(
    title: title,
    description: description,
    fullContent: fullContent,
    scrapedContent: scrapedContent,
    imageUrl: imageUrl,
    url: url,
    date: date,
    isContentScraped: isContentScraped,
  );

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fullContent: json['fullContent'] ?? json['description'] ?? '',
      scrapedContent: json['scrapedContent'] ?? '',
      imageUrl: json['urlToImage'] ?? json['imageUrl'] ?? '',
      url: json['url'] ?? '',
      date: json['publishedAt'] ?? json['date'] ?? '',
      isContentScraped: json['isContentScraped'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'fullContent': fullContent,
      'scrapedContent': scrapedContent,
      'imageUrl': imageUrl,
      'url': url,
      'date': date,
      'isContentScraped': isContentScraped,
    };
  }
}