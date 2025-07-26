// lib/features/news/data/repositories/news_repository_impl.dart
import 'package:http/http.dart' as http;
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_api_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsApiDataSource dataSource;

  NewsRepositoryImpl(this.dataSource);

  @override
  Future<List<Article>> fetchNews(String category, int page) async {
    return await dataSource.fetchNews(category, page);
  }
}
