import '../entities/weather.dart';
import '../entities/location_suggestion.dart';

abstract class WeatherRepository {
  // Fetch weather by city name
  Future<Weather> getWeather(String city);

  // Fetch weather by coordinates (latitude and longitude)
  Future<Weather> fetchWeatherByLocation(double lat, double lon);

  // Search for location suggestions using city name
  Future<List<LocationSuggestion>> searchLocations(String query);
}