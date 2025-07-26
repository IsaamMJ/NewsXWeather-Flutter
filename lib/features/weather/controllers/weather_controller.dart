import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../domain/usecases/get_weather_usecase.dart';
import '../domain/entities/weather.dart';

class WeatherController extends GetxController {
  final GetWeatherUseCase getWeatherUseCase;
  RxBool isLoading = true.obs;
  Weather? weather; // The weather data, which can be null initially
  String selectedTemperatureUnit = 'Celsius';

  WeatherController(this.getWeatherUseCase);

  @override
  void onInit() {
    super.onInit();
    // Only fetch location and weather if there's no weather data
    if (weather == null) {
      fetchCurrentLocation();
    }
    _loadTemperatureUnit();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied.");
        isLoading.value = false;
        update();
        return;
      }

      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        print("No internet connection.");
        isLoading.value = false;
        update();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Current Location: Lat: ${position.latitude}, Lon: ${position.longitude}");

      fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      print("Error fetching location: $e");
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchWeather(double lat, double lon) async {
    try {
      // Prevent unnecessary fetch if weather data is already available
      if (weather != null) return;

      isLoading.value = true;
      update();

      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        print("No internet connection.");
        isLoading.value = false;
        update();
        return;
      }

      print("Fetching weather for location: Lat: $lat, Lon: $lon");

      weather = await getWeatherUseCase
          .fetchWeatherByLocation(lat, lon)
          .timeout(const Duration(seconds: 50));

      print("Weather Data: City: ${weather?.city}, Temp: ${weather?.temperature}°C, Humidity: ${weather?.humidity}%");

    } on TimeoutException {
      print("Weather API timed out.");
    } on SocketException catch (e) {
      print("SocketException: $e");
    } catch (e) {
      print("Error fetching weather data: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _loadTemperatureUnit() async {
    final prefs = await SharedPreferences.getInstance();
    selectedTemperatureUnit = prefs.getString('temperatureUnit') ?? 'Celsius';
    update();
  }

  Future<void> setTemperatureUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temperatureUnit', unit);
    selectedTemperatureUnit = unit;
    update();
  }

  // You can call this to clear the weather data when necessary
  void clearWeatherData() {
    weather = null;
    update();
  }
}
