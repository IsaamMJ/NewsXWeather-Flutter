import '../repositories/weather_repository.dart';
import '../entities/weather.dart';

class GetWeatherUseCase {
  final WeatherRepository repository;

  GetWeatherUseCase(this.repository);

  // Call with City Name
  Future<Weather> call(String city) async {
    return await repository.getWeather(city);
  }

  // Call with Latitude and Longitude
  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    return await repository.fetchWeatherByLocation(lat, lon);
  }
}
