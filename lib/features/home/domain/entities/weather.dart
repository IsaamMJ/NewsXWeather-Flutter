class Weather {
  final String city;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final List<WeatherForecast> forecast;

  Weather({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.forecast,
  });
}

class WeatherForecast {
  final String date;
  final double temperature;
  final String condition;

  WeatherForecast({
    required this.date,
    required this.temperature,
    required this.condition,
  });
}
