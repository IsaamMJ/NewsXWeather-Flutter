import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/weather_controller.dart';

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
            const Text(
              '5-Day Forecast',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Horizontal Forecast Scroll
            SizedBox(
              height: 100, // Increased height to accommodate content
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weather.forecast.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final day = weather.forecast[index];
                  return Container(
                    width: 80,
                    padding: const EdgeInsets.all(6), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Better spacing
                      mainAxisSize: MainAxisSize.min, // Use minimum space needed
                      children: [
                        Flexible( // Allow text to shrink if needed
                          child: Text(
                            day.date.split(' ')[0], // e.g., "Wednesday"
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12, // Smaller font size
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis, // Handle long day names
                          ),
                        ),
                        const Flexible(
                          child: Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 20, // Smaller icon
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${day.temperature}°C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12, // Smaller font size
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
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