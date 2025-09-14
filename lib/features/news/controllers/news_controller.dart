// lib/features/news/presentation/controllers/news_controller.dart
import 'package:get/get.dart';
import '../../../../core/constants/api_routes.dart';
import '../../settings/controller/settings_controller.dart';
import '../domain/entities/article.dart';
import '../domain/usecases/get_news_usecase.dart';
import '../data/datasources/rss_news_datasource.dart';

// Import your existing InAppWebView page
import '../presentation/pages/in_app_web_view.dart';

class NewsController extends GetxController {
  final GetNewsUseCase getNewsUseCase;

  // Observable states
  RxBool isLoading = true.obs;
  RxBool isRefreshing = false.obs;
  RxList<Article> articles = <Article>[].obs;
  RxString errorMessage = ''.obs;
  RxBool hasError = false.obs;

  // Last successful fetch timestamp
  Rx<DateTime?> lastFetchTime = Rx<DateTime?>(null);

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
      if (!isRefreshing.value) {
        isLoading.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      final selectedCategories = Get.find<SettingsController>().selectedCategories;

      // Map to RSS categories and deduplicate
      final categoryMapping = {
        'business': 'business',
        'entertainment': 'entertainment',
        'lifestyle': 'entertainment',
        'health': 'health',
        'science': 'science',
        'sports': 'sports',
        'technology': 'technology',
      };

      final rssCategories = selectedCategories
          .map((cat) => categoryMapping[cat] ?? 'general')
          .toSet();

      List<Article> allArticles = [];
      List<String> failedCategories = [];
      int successfulCategories = 0;

      for (String rssCategory in rssCategories) {
        try {
          final categoryArticles = await getNewsUseCase.call(rssCategory, 1);
          if (categoryArticles.isNotEmpty) {
            allArticles.addAll(categoryArticles);
            successfulCategories++;
          } else {
            failedCategories.add(rssCategory);
          }
        } catch (e) {
          print('[NewsController] Error fetching $rssCategory: $e');
          failedCategories.add(rssCategory);
        }
      }

      // Handle results
      if (allArticles.isNotEmpty) {
        // Success: we got some articles
        final uniqueArticles = _removeDuplicateArticles(allArticles);
        uniqueArticles.sort((a, b) => b.date.compareTo(a.date));
        articles.value = uniqueArticles;
        lastFetchTime.value = DateTime.now();

        // Show partial success message if some categories failed
        if (failedCategories.isNotEmpty && successfulCategories > 0) {
          _showPartialSuccessMessage(failedCategories.length, rssCategories.length);
        }

      } else {
        // Complete failure: no articles fetched
        hasError.value = true;
        errorMessage.value = 'Unable to load news from any source. Please check your internet connection.';

        // Show user-friendly error message
        Get.snackbar(
          'News Update Failed',
          'Could not fetch latest news. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }

    } catch (e) {
      print('[NewsController] General error: $e');
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred while loading news.';

      Get.snackbar(
        'Error',
        'Failed to load news. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // Enhanced refresh with user feedback
  Future<void> refreshNews() async {
    if (isLoading.value) return; // Prevent double refresh

    try {
      isRefreshing.value = true;

      // Clear cache to force fresh data
      RssNewsDataSource.clearCache();

      // Show refresh feedback
      Get.snackbar(
        'Refreshing News',
        'Fetching latest articles...',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );

      await fetchNews();

      if (!hasError.value) {
        Get.snackbar(
          'News Updated',
          'Latest articles loaded successfully',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }

    } catch (e) {
      print('[NewsController] Refresh error: $e');
      Get.snackbar(
        'Refresh Failed',
        'Could not update news. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // Open article in InAppWebView - UPDATED METHOD
  void openArticle(Article article) {
    if (article.url.isEmpty) {
      Get.snackbar(
        'Error',
        'Article link is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Open in InAppWebView
    Get.to(
          () => InAppWebViewPage(
        url: article.url,
        title: article.title.length > 30
            ? '${article.title.substring(0, 30)}...'
            : article.title,
      ),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Utility methods
  List<Article> _removeDuplicateArticles(List<Article> articles) {
    final seen = <String>{};
    return articles.where((article) {
      final key = '${article.title.toLowerCase().trim()}_${article.url}';
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  void _showPartialSuccessMessage(int failedCount, int totalCount) {
    Get.snackbar(
      'Partial Update',
      'Loaded news from ${totalCount - failedCount}/$totalCount sources',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // Getters for UI
  int getArticleCount() => articles.length;

  bool get isDataStale {
    if (lastFetchTime.value == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastFetchTime.value!);
    return difference.inMinutes > 30; // Consider stale after 30 minutes
  }

  String get lastUpdateText {
    if (lastFetchTime.value == null) return 'Never updated';

    final now = DateTime.now();
    final difference = now.difference(lastFetchTime.value!);

    if (difference.inMinutes < 1) {
      return 'Updated just now';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Updated ${difference.inHours}h ago';
    } else {
      return 'Updated ${difference.inDays}d ago';
    }
  }

  // Search functionality
  List<Article> searchArticles(String query) {
    if (query.isEmpty) return articles;

    final lowercaseQuery = query.toLowerCase();
    return articles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
          article.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Force refresh without cache
  Future<void> forceRefresh() async {
    RssNewsDataSource.clearCache();
    await refreshNews();
  }
}