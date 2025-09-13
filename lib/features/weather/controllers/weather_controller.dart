import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../domain/usecases/get_weather_usecase.dart';
import '../domain/entities/weather.dart';
import '../domain/entities/location_suggestion.dart';

class WeatherController extends GetxController {
  final GetWeatherUseCase getWeatherUseCase;
  RxBool isLoading = true.obs;
  Weather? weather; // The weather data, which can be null initially
  String selectedTemperatureUnit = 'Celsius';

  // Location management
  bool isUsingManualLocation = false;
  LocationSuggestion? savedLocation;

  WeatherController(this.getWeatherUseCase);

  @override
  void onInit() {
    super.onInit();
    _initializeWeatherData();
    _loadTemperatureUnit();
  }

  Future<void> _initializeWeatherData() async {
    // Load saved location preference first
    await _loadLocationPreference();

    // Fetch weather based on saved preference
    if (isUsingManualLocation && savedLocation != null) {
      fetchWeather(savedLocation!.lat, savedLocation!.lon);
    } else {
      fetchCurrentLocation();
    }
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

  // NEW: Search for location suggestions
  Future<List<LocationSuggestion>> searchLocations(String query) async {
    try {
      return await getWeatherUseCase.searchLocations(query);
    } catch (e) {
      print("Error searching locations: $e");
      throw e;
    }
  }

  // NEW: Set manual location and fetch weather
  Future<void> setManualLocation(LocationSuggestion location) async {
    try {
      savedLocation = location;
      isUsingManualLocation = true;

      // Save preference
      await _saveLocationPreference();

      // Clear current weather data and fetch new
      weather = null;
      await fetchWeather(location.lat, location.lon);
    } catch (e) {
      print("Error setting manual location: $e");
    }
  }

  // NEW: Use current GPS location
  Future<void> useCurrentLocation() async {
    try {
      isUsingManualLocation = false;
      savedLocation = null;

      // Save preference
      await _saveLocationPreference();

      // Clear current weather data and fetch GPS location
      weather = null;
      await fetchCurrentLocation();
    } catch (e) {
      print("Error using current location: $e");
    }
  }

  // NEW: Save location preference to SharedPreferences
  Future<void> _saveLocationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isUsingManualLocation', isUsingManualLocation);

      if (isUsingManualLocation && savedLocation != null) {
        await prefs.setString('savedLocationName', savedLocation!.name);
        await prefs.setString('savedLocationCountry', savedLocation!.country);
        await prefs.setString('savedLocationState', savedLocation!.state ?? '');
        await prefs.setDouble('savedLocationLat', savedLocation!.lat);
        await prefs.setDouble('savedLocationLon', savedLocation!.lon);
      } else {
        // Clear saved location data
        await prefs.remove('savedLocationName');
        await prefs.remove('savedLocationCountry');
        await prefs.remove('savedLocationState');
        await prefs.remove('savedLocationLat');
        await prefs.remove('savedLocationLon');
      }
    } catch (e) {
      print("Error saving location preference: $e");
    }
  }

  // NEW: Load location preference from SharedPreferences
  Future<void> _loadLocationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isUsingManualLocation = prefs.getBool('isUsingManualLocation') ?? false;

      if (isUsingManualLocation) {
        final name = prefs.getString('savedLocationName');
        final country = prefs.getString('savedLocationCountry');
        final state = prefs.getString('savedLocationState');
        final lat = prefs.getDouble('savedLocationLat');
        final lon = prefs.getDouble('savedLocationLon');

        if (name != null && country != null && lat != null && lon != null) {
          savedLocation = LocationSuggestion(
            name: name,
            country: country,
            state: state?.isNotEmpty == true ? state : null,
            lat: lat,
            lon: lon,
          );
        } else {
          // Data is corrupted, reset to GPS
          isUsingManualLocation = false;
        }
      }
    } catch (e) {
      print("Error loading location preference: $e");
      // On error, default to GPS location
      isUsingManualLocation = false;
      savedLocation = null;
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

  // NEW: Get current location type for UI display
  String getCurrentLocationInfo() {
    if (isUsingManualLocation && savedLocation != null) {
      return "Manual: ${savedLocation!.displayName}";
    }
    return "Current GPS Location";
  }
}