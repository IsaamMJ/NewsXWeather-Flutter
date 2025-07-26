// lib/features/news/domain/repositories/news_repository.dart
import '../entities/article.dart';

abstract class NewsRepository {
  // Fetch news articles by category and page
  Future<List<Article>> fetchNews(String category, int page);
}
