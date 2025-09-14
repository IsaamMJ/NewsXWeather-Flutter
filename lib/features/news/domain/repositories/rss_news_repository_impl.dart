import 'package:http/http.dart' as http;
import '../../data/datasources/rss_news_datasource.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';

class RssNewsRepositoryImpl implements NewsRepository {
  final RssNewsDataSource dataSource;

  RssNewsRepositoryImpl(this.dataSource);

  @override
  Future<List<Article>> fetchNews(String category, int page) async {
    return await dataSource.fetchNews(category, page);
  }
}