import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/article.dart';
import '../domain/usecases/get_news_usecase.dart';
import '../../weather/controllers/weather_controller.dart';

class NewsController extends GetxController {
  final GetNewsUseCase getNewsUseCase;
  RxBool isLoading = true.obs;
  RxList<Article> articles = <Article>[].obs;

  NewsController(this.getNewsUseCase);

  final Map<String, List<String>> moodKeywords = {
    'cold': ['tragedy', 'depress', 'death'],
    'hot': ['danger', 'heatwave', 'alert'],
    'warm': ['win', 'hope', 'happy', 'celebrate'],
  };

  @override
  void onInit() {
    super.onInit();
    print('[NewsController] Initialized');
    fetchWeatherBasedNews();
  }

  Future<void> fetchWeatherBasedNews() async {
    try {
      isLoading.value = true;

      // Get selected categories from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final selectedCategories = prefs.getStringList('newsCategories') ?? ['technology'];

      // Get weather info from WeatherController
      final weatherController = Get.find<WeatherController>();
      final temperature = weatherController.weather?.temperature ?? 25;

      // Determine mood
      String mood = _getMoodFromTemperature(temperature);
      print('[NewsController] Detected mood: $mood');

      List<Article> allArticles = [];

      for (String category in selectedCategories) {
        final articles = await getNewsUseCase.call(category, 1);
        allArticles.addAll(articles);
      }

      // Filter articles based on mood keywords
      final keywords = moodKeywords[mood] ?? [];
      articles.value = allArticles.where((article) {
        final content = '${article.title} ${article.description}'.toLowerCase();
        return keywords.any((keyword) => content.contains(keyword));
      }).toList();

      print('[NewsController] Showing ${articles.length} filtered articles');

    } catch (e) {
      print('[NewsController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getMoodFromTemperature(double temp) {
    if (temp <= 15) return 'cold';
    if (temp >= 30) return 'hot';
    return 'warm';
  }
}
