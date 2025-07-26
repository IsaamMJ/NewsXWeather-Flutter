import 'dart:convert';
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

    // Debugging: Log the request URL
    print('Requesting news for category: $category, page: $page');
    print('Request URL: $url');

    try {
      final response = await client.get(url);

      // Debugging: Log the response status and body
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Article> articles = [];

        // Debugging: Log the number of articles fetched
        print('Found ${data['articles'].length} articles for category: $category');

        for (var article in data['articles']) {
          articles.add(Article.fromJson(article));
        }

        return articles;
      } else {
        // Debugging: Log the error if status code is not 200
        print('Error: Failed to load news. Status code: ${response.statusCode}');
        throw Exception('Failed to load news');
      }
    } catch (e) {
      // Debugging: Log the error in case of an exception
      print('Error fetching news for category: $category, page: $page: $e');
      throw Exception('Failed to load news');
    }
  }
}
