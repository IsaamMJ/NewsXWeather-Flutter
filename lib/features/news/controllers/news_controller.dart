import 'package:get/get.dart';
import '../domain/entities/article.dart';
import '../domain/usecases/get_news_usecase.dart';

class NewsController extends GetxController {
  final GetNewsUseCase getNewsUseCase;
  RxBool isLoading = true.obs;
  RxList<Article> articles = <Article>[].obs;

  NewsController(this.getNewsUseCase);

  @override
  void onInit() {
    super.onInit(); // You can update the category dynamically later
  }

  Future<void> fetchNews(String category, int page) async {
    try {
      isLoading.value = true;
      print("Requesting news for category: $category, page: $page");

      // Fetching news
      articles.value = await getNewsUseCase.call(category, page);

      // Check if articles were fetched
      print("Fetched ${articles.length} articles for category: $category, page: $page");

      // Notify that data has been fetched
      isLoading.value = false;
    } catch (e) {
      print("Error fetching news: $e");
      isLoading.value = false;  // Stop loading in case of error
    }
  }
}
