import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controllers/weather_controller.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/usecases/get_weather_usecase.dart';
import '../widgets/weather_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies only once and store the controller globally in memory
    // Ensuring that the controller is available throughout the app
    Get.lazyPut(() => WeatherController(GetWeatherUseCase(WeatherRepositoryImpl(http.Client()))));

    return Scaffold(
      body: Column(
        children: [
          WeatherWidget(), // Weather Widget that displays weather data
          // Below this, we can add the news widget once implemented
        ],
      ),
    );
  }
}
