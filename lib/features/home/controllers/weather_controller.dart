import 'package:get/get.dart';
import '../domain/usecases/get_weather_usecase.dart';
import '../domain/entities/weather.dart';
import 'package:geolocator/geolocator.dart';  // For getting current location

class WeatherController extends GetxController {
  final GetWeatherUseCase getWeatherUseCase;
  RxBool isLoading = true.obs;
  Weather? weather;

  WeatherController(this.getWeatherUseCase);

  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation();  // Fetch current location on init
  }

  // Fetch current location (latitude and longitude)
  Future<void> fetchCurrentLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Handle permission denial
        print("Location permissions are permanently denied.");
        isLoading.value = false; // Stop loading as permission is denied
        update();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("Current Location: Lat: ${position.latitude}, Lon: ${position.longitude}");

      // Fetch weather data for the obtained location
      fetchWeather(position.latitude, position.longitude);  // Pass lat, lon to weather API
    } catch (e) {
      print("Error fetching location: $e");
      isLoading.value = false;  // Stop loading if there is an error fetching location
      update();
    }
  }

  // Fetch weather data by latitude and longitude
  Future<void> fetchWeather(double lat, double lon) async {
    try {
      isLoading.value = true;
      update();

      // Debugging: log the coordinates
      print("Fetching weather for location: Lat: $lat, Lon: $lon");

      weather = await getWeatherUseCase.fetchWeatherByLocation(lat, lon);  // Fetch weather by location

      // Debugging: log the weather response
      print("Weather Data: City: ${weather?.city}, Temp: ${weather?.temperature}°C, Humidity: ${weather?.humidity}%");

      isLoading.value = false;
      update(); // Ensure that UI is updated
    } catch (e) {
      print("Error fetching weather data: $e");
      isLoading.value = false;
      update();  // Stop loading and update UI
    }
  }
}
