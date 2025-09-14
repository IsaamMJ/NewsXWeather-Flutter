// lib/features/home/presentation/pages/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/network/api_client.dart';
import '../../../../news/controllers/news_controller.dart';
import '../../../../news/data/datasources/rss_news_datasource.dart';
import '../../../../news/domain/repositories/rss_news_repository_impl.dart';
import '../../../../news/domain/usecases/get_news_usecase.dart';
import '../../../../news/presentation/widgets/news_widget.dart';

import '../../../../settings/controller/settings_controller.dart';
import '../../../../weather/controllers/weather_controller.dart';
import '../../../../weather/data/repositories/weather_repository_impl.dart';
import '../../../../weather/domain/usecases/get_weather_usecase.dart';
import '../../../../weather/presentation/widgets/weather_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();
    final apiClient = ApiClient(httpClient);

    // Initialize SettingsController before NewsController
    Get.lazyPut(() => SettingsController());

    // Lazy initialize WeatherController, but only if not already loaded
    Get.lazyPut(() => WeatherController(GetWeatherUseCase(WeatherRepositoryImpl(httpClient))));

    // Initialize RSS-based NewsController (no web scraping, uses InAppWebView)
    Get.lazyPut(() {
      final rssDataSource = RssNewsDataSource(httpClient);
      final repository = RssNewsRepositoryImpl(rssDataSource);
      final useCase = GetNewsUseCase(repository);

      return NewsController(useCase); // Only RSS, no WebScraperService needed
    });

    final newsController = Get.find<NewsController>();
    final weatherController = Get.find<WeatherController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh both news and weather
            await Future.wait([
              newsController.refreshNews(),
              // Optionally refresh weather too
              // weatherController.fetchWeather(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // WeatherWidget should not rebuild unless necessary
                Obx(() {
                  return weatherController.isLoading.value
                      ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : const WeatherWidget(); // Display the Weather widget
                }),

                // NewsWidget with enhanced loading states
                Obx(() {
                  if (newsController.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Loading latest news...',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (newsController.hasError.value) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load news',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              newsController.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => newsController.refreshNews(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const NewsWidget(); // Display the News widget - opens articles in InAppWebView
                }),

                // Bottom spacing
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // Floating Action Button for manual refresh
      floatingActionButton: Obx(() {
        if (newsController.isRefreshing.value || newsController.isLoading.value) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () => newsController.forceRefresh(),
          tooltip: 'Refresh News',
          child: const Icon(Icons.refresh),
        );
      }),
    );
  }
}