import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PollinationsService {
  final String baseUrl = 'https://text.pollinations.ai/';
  final String model = 'openai-large';

  /// Generates a creative activity suggestion based on the given weather condition and temperature
  /// Returns a generated activity description or throws an exception if the request fails
  Future<String> generateActivitySuggestion({
    required String weatherCondition,
    required double temperature,
    required bool isSunny,
  }) async {
    try {
      // Create a prompt based on weather conditions
      final String prompt = _createPrompt(
        weatherCondition,
        temperature,
        isSunny,
      );

      // Make the API request
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'model': model,
          'private': true, // Response won't appear in public feed
        }),
      );

      if (response.statusCode == 200) {
        // Return the generated text
        return response.body;
      } else {
        throw Exception(
          'Failed to generate activity suggestion: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error generating activity suggestion: $e');
      throw Exception('Failed to connect to Pollinations API: $e');
    }
  }

  /// Creates a prompt for the AI based on weather conditions
  String _createPrompt(
    String weatherCondition,
    double temperature,
    bool isSunny,
  ) {
    String basePrompt =
        '请根据以下天气情况，推荐一个创意十足的活动，并提供简短的描述（不超过100字）。请推荐一些有趣、有创意、适合当前天气的活动，可以是户外或室内活动。';

    String weatherDescription = '当前天气：$weatherCondition，温度：$temperature°C';
    if (isSunny) {
      weatherDescription += '，天气晴朗';
    }

    String formatInstruction = '请直接给出活动名称和描述，不要包含任何其他内容。格式为：活动名称：活动描述';

    return '$basePrompt\n$weatherDescription\n$formatInstruction';
  }
}
