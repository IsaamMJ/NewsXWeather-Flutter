import 'package:http/http.dart' as http;
import 'package:skyfeed/features/news/data/datasources/rss_news_datasource.dart';

class RssNewsDataSourceFactory {
  static RssNewsDataSource create() {
    return RssNewsDataSource(http.Client());
  }
}