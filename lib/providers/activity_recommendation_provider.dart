import 'package:flutter/foundation.dart';
import '../models/activity_suggestion.dart';
import '../models/weather.dart';
import '../services/pollinations_service.dart';

class ActivityRecommendationProvider with ChangeNotifier {
  final PollinationsService _pollinationsService = PollinationsService();

  ActivitySuggestion? _aiGeneratedSuggestion;
  bool _isLoading = false;
  String? _errorMessage;

  ActivitySuggestion? get aiGeneratedSuggestion => _aiGeneratedSuggestion;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Generates a new activity suggestion using the Pollinations API
  Future<void> generateActivitySuggestion(Weather weather) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String generatedText = await _pollinationsService
          .generateActivitySuggestion(
            weatherCondition: weather.condition,
            temperature: weather.temperature,
            isSunny: weather.isSunny,
          );

      // Parse the generated text to extract title and description
      final parsedSuggestion = _parseGeneratedText(generatedText);

      _aiGeneratedSuggestion = ActivitySuggestion(
        title: parsedSuggestion['title'] ?? '智能推荐活动',
        description: parsedSuggestion['description'] ?? generatedText,
        iconName: _getIconNameForWeather(weather.condition),
        weatherConditions: [weather.condition],
        isAiGenerated: true,
      );
    } catch (e) {
      _errorMessage = '无法生成活动建议: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parses the generated text to extract title and description
  Map<String, String> _parseGeneratedText(String text) {
    try {
      // Try to extract title and description based on the expected format
      if (text.contains('：')) {
        final parts = text.split('：');
        if (parts.length >= 2) {
          return {
            'title': parts[0].trim(),
            'description': parts.sublist(1).join('：').trim(),
          };
        }
      }

      // If we can't parse it in the expected format, use a default approach
      final lines = text.split('\n');
      if (lines.length > 1) {
        return {
          'title': lines[0].trim(),
          'description': lines.sublist(1).join('\n').trim(),
        };
      }

      // If all else fails, use the whole text as description
      return {'title': '智能推荐活动', 'description': text.trim()};
    } catch (e) {
      debugPrint('Error parsing generated text: $e');
      return {'title': '智能推荐活动', 'description': text.trim()};
    }
  }

  /// Gets an appropriate icon name based on weather condition
  String _getIconNameForWeather(String condition) {
    switch (condition) {
      case 'Clear':
        return 'sunny';
      case 'Clouds':
        return 'walk';
      case 'Rain':
        return 'indoor';
      case 'Snow':
        return 'indoor';
      default:
        return 'sunny';
    }
  }
}
