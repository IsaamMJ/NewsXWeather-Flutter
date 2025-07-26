import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/weather_controller.dart';
import '../../../../core/theme/app_colors.dart'; // Import AppColors for dynamic colors

class ForecastItemWidget extends StatelessWidget {
  final String day;
  final String temperature;

  const ForecastItemWidget({
    Key? key,
    required this.day,
    required this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Text(
              day, // e.g., "Wednesday"
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Icon(
              Icons.wb_sunny,
              color: AppColors.getTextPrimary(context),
              size: 20,
            ),
          ),
          Flexible(
            child: Text(
              '$temperature°C',
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ForecastWidget extends StatelessWidget {
  const ForecastWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WeatherController>(
      builder: (controller) {
        final weather = controller.weather!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static header part - No rebuild
            Text(
              '5-Day Forecast',
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Horizontal Forecast Scroll
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weather.forecast.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final day = weather.forecast[index];

                  // Wrap only the dynamic forecast data in GetBuilder
                  return GetBuilder<WeatherController>(
                    id: 'forecast_${day.date}', // Unique ID to track changes for each forecast
                    builder: (_) {
                      return ForecastItemWidget(
                        day: day.date.split(' ')[0], // e.g., "Wednesday"
                        temperature: day.temperature.toString(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
