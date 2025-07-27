import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../../core/constants/api_routes.dart';
import '../../settings/controller/settings_controller.dart';
import '../../weather/controllers/weather_controller.dart';
import '../domain/entities/article.dart';
import '../domain/usecases/get_news_usecase.dart';
import '../presentation/widgets/news_widget.dart';

class NewsController extends GetxController {
  final GetNewsUseCase getNewsUseCase;
  RxBool isLoading = true.obs;
  RxList<Article> articles = <Article>[].obs;
  RxString mood = ''.obs;  // Store the mood here

  NewsController(this.getNewsUseCase);

  final Map<String, List<String>> moodKeywords = {
    'cold': ['tragedy', 'depress', 'death'],
    'hot': ['danger', 'heatwave', 'alert'],
    'warm': ['win', 'hope', 'happy', 'celebrate'],
  };

  @override
  void onInit() {
    super.onInit();
    fetchWeatherBasedNews();
    ever(Get.find<SettingsController>().selectedCategories, (_) => fetchWeatherBasedNews());
  }

  Future<void> fetchWeatherBasedNews() async {
    try {
      isLoading.value = true;

      // Get selected categories from SettingsController
      final selectedCategories = Get.find<SettingsController>().selectedCategories;

      // Get weather info from WeatherController
      final weatherController = Get.find<WeatherController>();
      final temperature = weatherController.weather?.temperature ?? 25;

      // Determine mood based on temperature
      String detectedMood = _getMoodFromTemperature(temperature);
      mood.value = detectedMood;

      List<Article> allArticles = [];
      // Fetch articles for each category
      for (String category in selectedCategories) {
        final articles = await getNewsUseCase.call(category, 1); // Fetch articles based on category
        allArticles.addAll(articles);
      }

      // Filter articles based on mood keywords
      final keywords = moodKeywords[detectedMood] ?? [];
      articles.value = allArticles.where((article) {
        final content = '${article.title} ${article.description}'.toLowerCase();
        return keywords.any((keyword) => content.contains(keyword));
      }).toList();

    } catch (e) {
      print('[NewsController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getMoodFromTemperature(double temp) {
    if (temp <= 15) return 'cold'; // Cold mood
    if (temp >= 30) return 'hot';  // Hot mood
    return 'warm'; // Warm mood
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
