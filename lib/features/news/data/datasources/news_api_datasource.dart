import 'package:skyfeed/core/network/api_client.dart';
import '../../../../core/constants/api_routes.dart';
import '../../domain/entities/article.dart';
import '../models/article_model.dart';
class NewsApiDataSource {
  final ApiClient apiClient;
  final String apiKey;

  NewsApiDataSource(this.apiClient, this.apiKey);

  Future<List<Article>> fetchNews(String category, int page) async {
    // Map categories to NewsAPI supported categories
    final categoryMapping = {
      'business': 'business',
      'entertainment': 'entertainment',
      'lifestyle': 'entertainment', // Maps to entertainment for lifestyle content
      'health': 'health',
      'science': 'science',
      'sports': 'sports',
      'technology': 'technology',
    };

    final apiCategory = categoryMapping[category] ?? 'general';

    final queryParams = {
      'category': apiCategory,
      'apiKey': apiKey,
      'page': page.toString(),
    };

    final data = await apiClient.get(ApiRoutes.news, queryParams: queryParams);

    if (data['articles'] == null) return [];

    return (data['articles'] as List)
        .map((json) => ArticleModel.fromJson(json))
        .toList();
  }
}
