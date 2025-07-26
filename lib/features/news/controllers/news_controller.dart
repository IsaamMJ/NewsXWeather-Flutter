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
    super.onInit();
    print('[NewsController] Initialized');
    fetchNews('technology', 1);
    // Optionally call fetchNews here if you always want it on startup
    // fetchNews('technology', 1);
  }

  Future<void> fetchNews(String category, int page) async {
    try {
      print('[NewsController] fetchNews() called');
      isLoading.value = true;
      print('[NewsController] Loading set to true');

      print("Requesting news for category: $category, page: $page");

      final result = await getNewsUseCase.call(category, page);
      print('[NewsController] API call successful, received ${result.length} articles');

      articles.value = result;

      isLoading.value = false;
      print('[NewsController] Loading set to false');
    } catch (e) {
      print("Error fetching news: $e");
      isLoading.value = false;
      print('[NewsController] Loading set to false (with error)');
    }
  }
}
