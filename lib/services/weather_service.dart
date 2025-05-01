import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../services/settings_service.dart';

class WeatherService {
  // API key is now provided by the SettingsService
  final SettingsService settingsService;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherService({required this.settingsService});

  Future<Weather> getCurrentWeather(double latitude, double longitude) async {
    // Check if API key is available
    final apiKey = settingsService.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Weather API key not set. Please set it in the settings.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      return Weather.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<List<Weather>> getForecast(double latitude, double longitude) async {
    // Check if API key is available
    final apiKey = settingsService.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Weather API key not set. Please set it in the settings.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> forecastList = data['list'];

      return forecastList.map((item) => Weather.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load forecast data: ${response.statusCode}');
    }
  }

  // Get weather icon URL
  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  // Check if the weather is sunny
  bool isSunnyWeather(Weather weather) {
    return weather.isSunny;
  }
}
