// lib/features/news/data/models/article_model.dart

import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required String title,
    required String description,
    required String imageUrl,
    required String url,
    required String date,
  }) : super(
    title: title,
    description: description,
    imageUrl: imageUrl,
    url: url,
    date: date,
  );

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      date: json['publishedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': imageUrl,
      'url': url,
      'publishedAt': date,
    };
  }
}
