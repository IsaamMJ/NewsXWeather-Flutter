// lib/features/news/domain/usecases/get_news_usecase.dart
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetNewsUseCase {
  final NewsRepository repository;

  GetNewsUseCase(this.repository);

  Future<List<Article>> call(String category, int page) async {
    return await repository.fetchNews(category, page);
  }
}
