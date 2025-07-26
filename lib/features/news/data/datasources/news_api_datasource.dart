import 'package:skyfeed/core/network/api_client.dart';
import '../../../../core/constants/api_routes.dart';
import '../../domain/entities/article.dart';
import '../models/article_model.dart';
class NewsApiDataSource {
  final ApiClient apiClient;
  final String apiKey;

  NewsApiDataSource(this.apiClient, this.apiKey);

  Future<List<Article>> fetchNews(String category, int page) async {
    final queryParams = {
      'category': category,
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
