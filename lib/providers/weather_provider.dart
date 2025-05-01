import 'package:flutter/foundation.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService;
  final LocationService _locationService = LocationService();

  WeatherProvider({required SettingsService settingsService})
    : _weatherService = WeatherService(settingsService: settingsService);

  Weather? _currentWeather;
  List<Weather> _forecast = [];
  bool _isLoading = false;
  String? _errorMessage;

  Weather? get currentWeather => _currentWeather;
  List<Weather> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSunny => _currentWeather?.isSunny ?? false;

  Future<void> fetchCurrentWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _currentWeather = await _weatherService.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      // Check if the error is related to missing API key
      if (e.toString().contains('API key not set')) {
        _errorMessage = '请在设置中配置天气API密钥';
      } else {
        _errorMessage = '获取天气数据失败: $e';
      }
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchForecast() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _forecast = await _weatherService.getForecast(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      // Check if the error is related to missing API key
      if (e.toString().contains('API key not set')) {
        _errorMessage = '请在设置中配置天气API密钥';
      } else {
        _errorMessage = '获取天气预报失败: $e';
      }
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getWeatherIconUrl(String iconCode) {
    return _weatherService.getWeatherIconUrl(iconCode);
  }
}
