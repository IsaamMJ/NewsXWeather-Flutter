import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/weather_controller.dart';
import 'forecast_widget.dart';

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
        final temperatureUnit = controller.selectedTemperatureUnit;

        double convertTemperature(double temperature) {
          if (temperatureUnit == 'Fahrenheit') {
            return (temperature * 9 / 5) + 32;
          }
          return temperature;
        }

        String getTemperatureLabel(double tempCelsius) {
          if (tempCelsius >= 30) return 'Hot';
          if (tempCelsius >= 20) return 'Warm';
          if (tempCelsius >= 10) return 'Cool';
          return 'Cold';
        }

        final double displayTemp = convertTemperature(weather.temperature);
        final tempLabel = getTemperatureLabel(weather.temperature);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // City & Temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
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
                          '${displayTemp.toStringAsFixed(1)}°${temperatureUnit == 'Celsius' ? 'C' : 'F'}',
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tempLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.wb_cloudy_rounded, size: 48, color: Colors.white),
                ],
              ),
              const SizedBox(height: 16),

              // Humidity & Wind
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Humidity: ${weather.humidity.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.air, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Wind: ${weather.windSpeed.toStringAsFixed(1)} m/s',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Forecast
              const ForecastWidget(),
            ],
          ),
        );
      },
    );
  }
}