import '../entities/weather.dart';

abstract class WeatherRepository {
  // Fetch weather by city name
  Future<Weather> getWeather(String city);

  // Fetch weather by coordinates (latitude and longitude)
  Future<Weather> fetchWeatherByLocation(double lat, double lon);
}
