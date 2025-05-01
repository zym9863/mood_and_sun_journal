import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  static const String _apiKeyKey = 'weather_api_key';
  String? _apiKey;
  
  String? get apiKey => _apiKey;
  
  // Check if API key is set
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  // Initialize settings from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyKey);
    notifyListeners();
  }

  // Save API key to SharedPreferences
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
    _apiKey = apiKey;
    notifyListeners();
  }

  // Clear API key from SharedPreferences
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
    _apiKey = null;
    notifyListeners();
  }
}
