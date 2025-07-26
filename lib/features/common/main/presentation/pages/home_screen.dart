import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../news/controllers/news_controller.dart';
import '../../../../news/data/datasources/news_api_datasource.dart';
import '../../../../news/data/repositories/news_repository_impl.dart';
import '../../../../news/domain/usecases/get_news_usecase.dart';
import '../../../../news/presentation/widgets/news_widget.dart';
import '../../../../weather/controllers/weather_controller.dart';
import '../../../../weather/data/repositories/weather_repository_impl.dart';
import '../../../../weather/domain/usecases/get_weather_usecase.dart';
import '../../../../weather/presentation/widgets/weather_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lazy initialize controllers once
    Get.lazyPut(() =>
        WeatherController(GetWeatherUseCase(WeatherRepositoryImpl(http.Client()))));
    Get.lazyPut(() =>
        NewsController(GetNewsUseCase(NewsRepositoryImpl(NewsApiDataSource(http.Client())))));

    final newsController = Get.find<NewsController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => newsController.fetchWeatherBasedNews(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Ensures RefreshIndicator works
            child: Column(
              children: const [
                WeatherWidget(),
                NewsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
