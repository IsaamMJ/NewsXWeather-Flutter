import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../domain/entities/article.dart';

class NewsApiDataSource {
  final String apiKey = 'e6a16922a3304e69a273461981193627';
  final http.Client client;

  NewsApiDataSource(this.client);

  Future<List<Article>> fetchNews(String category, int page) async {
    final url = Uri.parse(
      'https://newsapi.org/v2/top-headlines?category=$category&apiKey=$apiKey&page=$page',
    );

    print('[NewsApiDataSource] Starting fetchNews');
    print('[NewsApiDataSource] Request URL: $url');

    try {
      final response = await client.get(url);

      print('[NewsApiDataSource] Response Status: ${response.statusCode}');
      if (response.body.isEmpty) {
        print('[NewsApiDataSource] Response Body is empty!');
      } else {
        final previewLength = min(response.body.length, 300);
        print('[NewsApiDataSource] Response Body: ${response.body.substring(0, previewLength)}...');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null || data['articles'] == null) {
          print('[NewsApiDataSource] JSON parsing failed or articles key missing');
          return [];
        }

        List<Article> articles = [];

        final items = data['articles'] as List;
        print('[NewsApiDataSource] Found ${items.length} articles for category: $category');

        for (int i = 0; i < items.length; i++) {
          try {
            articles.add(Article.fromJson(items[i]));
          } catch (e) {
            print('[NewsApiDataSource] Error parsing article at index $i: $e');
          }
        }

        return articles;
      } else {
        print('[NewsApiDataSource] Error: HTTP ${response.statusCode}');
        throw Exception('Failed to load news. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('[NewsApiDataSource] Exception occurred: $e');
      throw Exception('Failed to load news: $e');
    }
  }
}
