import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final http.Client client;
  final String apiKey = dotenv.env['WEATHER_API_KEY']!; // Fetch from .env

  WeatherRepositoryImpl(this.client);

  @override
  Future<Weather> getWeather(String city) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = Weather(
          city: data['name'],
          temperature: data['main']['temp'].toDouble(),
          humidity: data['main']['humidity'].toDouble(),
          windSpeed: data['wind']['speed'].toDouble(),
          forecast: [], // Empty forecast for now
        );
        return weather;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  @override
  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = Weather(
          city: data['name'],
          temperature: data['main']['temp'].toDouble(),
          humidity: data['main']['humidity'].toDouble(),
          windSpeed: data['wind']['speed'].toDouble(),
          forecast: await _getForecastByLocation(lat, lon),
        );
        return weather;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  // Fetch the 5-day forecast data and group by date
  Future<List<WeatherForecast>> _getForecastByLocation(double lat, double lon) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<WeatherForecast> forecastList = [];
        Map<String, WeatherForecast> forecastMap = {};

        // Filter and group forecast by date
        for (var item in data['list']) {
          final date = item['dt_txt'].split(' ')[0];  // Get the date part
          final temp = item['main']['temp'].toDouble();
          final weatherDescription = item['weather'][0]['description'];

          // If the date is not already added, add it to the map
          if (!forecastMap.containsKey(date)) {
            forecastMap[date] = WeatherForecast(
              date: date,
              temperature: temp,
              condition: weatherDescription,
            );
          }
        }

        // Convert the map values to a list
        forecastList = forecastMap.values.toList();

        return forecastList;
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Failed to load forecast data: $e');
    }
  }
}
