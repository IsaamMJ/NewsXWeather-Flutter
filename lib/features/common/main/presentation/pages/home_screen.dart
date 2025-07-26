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
    // Initialize dependencies only once and store the controller globally in memory
    // Ensuring that the controller is available throughout the app
    Get.lazyPut(() => WeatherController(GetWeatherUseCase(WeatherRepositoryImpl(http.Client()))));
    Get.lazyPut(() => NewsController(GetNewsUseCase(NewsRepositoryImpl(NewsApiDataSource(http.Client())))));

    return Scaffold(
      body: Column(
        children: [
          WeatherWidget(), // Weather Widget that displays weather data
          NewsWidget(),
          // Below this, we can add the news widget once implemented
        ],
      ),
    );
  }
}
