import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../news/controllers/news_controller.dart';
import '../../../../news/data/datasources/news_api_datasource.dart';
import '../../../../news/data/repositories/news_repository_impl.dart';
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

    // Lazy initialize NewsController with centralized ApiClient and secure API key
    Get.lazyPut(() => NewsController(
      GetNewsUseCase(
        NewsRepositoryImpl(
          NewsApiDataSource(apiClient, dotenv.env['NEWS_API_KEY']!),
        ),
      ),
    ));

    final newsController = Get.find<NewsController>();
    final weatherController = Get.find<WeatherController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh only the news, not the weather
            await newsController.fetchWeatherBasedNews();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // WeatherWidget should not rebuild unless necessary
                GetBuilder<WeatherController>(
                  builder: (_) {
                    return const WeatherWidget(); // Display the Weather widget
                  },
                ),
                // NewsWidget should be able to refresh independently
                GetBuilder<NewsController>(
                  builder: (_) {
                    return const NewsWidget(); // Display the News widget
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
