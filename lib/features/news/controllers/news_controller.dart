import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../../core/constants/api_routes.dart';
import '../../settings/controller/settings_controller.dart';
import '../domain/entities/article.dart';
import '../domain/usecases/get_news_usecase.dart';
import '../presentation/widgets/news_widget.dart';

class NewsController extends GetxController {
  final GetNewsUseCase getNewsUseCase;
  RxBool isLoading = true.obs;
  RxList<Article> articles = <Article>[].obs;

  NewsController(this.getNewsUseCase);

  @override
  void onInit() {
    super.onInit();
    fetchNews();
    // Listen to category changes and refresh news
    ever(Get.find<SettingsController>().selectedCategories, (_) => fetchNews());
  }

  Future<void> fetchNews() async {
    try {
      isLoading.value = true;

      // Get selected categories from SettingsController
      final selectedCategories = Get.find<SettingsController>().selectedCategories;

      List<Article> allArticles = [];

      // Fetch articles for each selected category
      for (String category in selectedCategories) {
        final categoryArticles = await getNewsUseCase.call(category, 1);
        allArticles.addAll(categoryArticles);
      }

      // Set all fetched articles
      articles.value = allArticles;

    } catch (e) {
      print('[NewsController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> launchArticleUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open the article externally. Opening inside the app.');
      Get.to(() => InAppWebViewPage(url: url));
    }
  }
}