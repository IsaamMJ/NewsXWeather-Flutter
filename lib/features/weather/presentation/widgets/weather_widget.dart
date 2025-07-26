import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart'; // Import your AppColors for styling
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

        // Convert temperature based on the selected unit (Celsius or Fahrenheit)
        double convertTemperature(double temperature) {
          if (temperatureUnit == 'Fahrenheit') {
            return (temperature * 9 / 5) + 32;
          }
          return temperature; // Default is Celsius
        }

        String getTemperatureLabel(double tempCelsius) {
          if (tempCelsius >= 30) return 'Hot';
          if (tempCelsius >= 20) return 'Warm';
          if (tempCelsius >= 10) return 'Cool';
          return 'Cold';
        }

        // Calculate the display temperature in the selected unit
        final double displayTemp = convertTemperature(weather.temperature);
        final tempLabel = getTemperatureLabel(weather.temperature);

        // Get the dynamic text color for light and dark themes
        Color textColor = AppColors.getTextPrimary(context);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context).withOpacity(0.9), // Dynamic card color based on theme
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.getAccent(context).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
            ],
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
                        // Static City Name (No rebuild needed)
                        Text(
                          weather.city,
                          style: TextStyle(
                            fontSize: 24,
                            color: textColor, // Dynamic text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Dynamic Temperature - wrapped in GetBuilder for updates
                        Text(
                          '${displayTemp.toStringAsFixed(1)}°${temperatureUnit == 'Celsius' ? 'C' : 'F'}',
                          style: TextStyle(
                            fontSize: 48,
                            color: textColor, // Dynamic text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Dynamic Temperature Label - wrapped in GetBuilder for updates
                        Text(
                          tempLabel,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.wb_cloudy_rounded, size: 48, color: textColor), // Dynamic icon color
                ],
              ),
              const SizedBox(height: 16),

              // Humidity & Wind
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: textColor), // Dynamic icon color
                      const SizedBox(width: 4),
                      // Dynamic Humidity - wrapped in GetBuilder for updates
                      Text(
                        'Humidity: ${weather.humidity.toStringAsFixed(0)}%',
                        style: TextStyle(color: textColor), // Dynamic text color
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.air, color: textColor), // Dynamic icon color
                      const SizedBox(width: 4),
                      // Dynamic Wind Speed - wrapped in GetBuilder for updates
                      Text(
                        'Wind: ${weather.windSpeed.toStringAsFixed(1)} m/s',
                        style: TextStyle(color: textColor), // Dynamic text color
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
