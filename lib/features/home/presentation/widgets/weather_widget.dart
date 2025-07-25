import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/weather_controller.dart';
import 'forecast_widget.dart';  // Import the new 5-day forecast widget

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WeatherController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.weather == null) {
          return const Center(child: Text('Failed to load weather data'));
        }

        final weather = controller.weather!;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(  // Make the entire column scrollable
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // City & Temperature
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.city,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${weather.temperature}°C',
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Hot',  // Update dynamically if necessary
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.wb_cloudy_rounded, size: 48, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),

                // Humidity and Wind
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Humidity: ${weather.humidity}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.air, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Wind: ${weather.windSpeed} m/s',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5-Day Forecast
                const ForecastWidget(),  // Display the forecast in a separate widget
              ],
            ),
          ),
        );
      },
    );
  }
}
