import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart'; // Import your AppColors for styling
import '../../controllers/weather_controller.dart';
import 'forecast_widget.dart';
import 'location_change_dialog.dart'; // Import the new dialog

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  void _showLocationChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const LocationChangeDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WeatherController>(
      builder: (controller) {
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
              // Location Header - ALWAYS VISIBLE
              _buildLocationHeader(context, controller, textColor),

              const SizedBox(height: 16),

              // Weather Content - Loading/Error/Success states
              if (controller.isLoading.value)
                _buildLoadingState()
              else if (controller.weather == null)
                _buildErrorState(textColor)
              else
                _buildWeatherContent(controller, textColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationHeader(BuildContext context, WeatherController controller, Color textColor) {
    // Show current location info even when weather data is null
    String locationName = 'Loading...';

    if (controller.weather != null) {
      locationName = controller.weather!.city;
    } else if (controller.isUsingManualLocation && controller.savedLocation != null) {
      locationName = controller.savedLocation!.name;
    } else if (!controller.isLoading.value) {
      locationName = 'Unknown Location';
    }

    return Row(
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // City Name with Location Change Button
              Row(
                children: [
                  Flexible(
                    child: Text(
                      locationName,
                      style: TextStyle(
                        fontSize: 24,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Location Change Button - ALWAYS VISIBLE
                  GestureDetector(
                    onTap: () => _showLocationChangeDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.getAccent(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_location_alt,
                        size: 20,
                        color: AppColors.getAccent(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Location Type Indicator
              if (controller.isUsingManualLocation)
                Text(
                  'Custom Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load weather data',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection or try a different location',
              style: TextStyle(
                color: AppColors.getTextSecondary(Get.context!),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherController controller, Color textColor) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Temperature Display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${displayTemp.toStringAsFixed(1)}°${temperatureUnit == 'Celsius' ? 'C' : 'F'}',
                  style: TextStyle(
                    fontSize: 48,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tempLabel,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextSecondary(Get.context!),
                  ),
                ),
              ],
            ),
            Icon(Icons.wb_cloudy_rounded, size: 48, color: textColor),
          ],
        ),
        const SizedBox(height: 16),

        // Humidity & Wind
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: textColor),
                const SizedBox(width: 4),
                Text(
                  'Humidity: ${weather.humidity.toStringAsFixed(0)}%',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.air, color: textColor),
                const SizedBox(width: 4),
                Text(
                  'Wind: ${weather.windSpeed.toStringAsFixed(1)} m/s',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Forecast
        const ForecastWidget(),
      ],
    );
  }
}