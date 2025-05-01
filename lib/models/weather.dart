class Weather {
  final String condition;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String icon;
  final DateTime timestamp;
  final bool isSunny;

  Weather({
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.timestamp,
    required this.isSunny,
  });

  factory Weather.fromMap(Map<String, dynamic> map) {
    // This is a simplified example. You'll need to adapt this to the actual API response
    final weather = map['weather'][0];
    final main = map['main'];
    final wind = map['wind'];
    
    // Check if the weather condition indicates sunny weather
    final isSunny = weather['main'] == 'Clear' || 
                    (weather['main'] == 'Clouds' && weather['description'].contains('few'));

    return Weather(
      condition: weather['main'],
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'],
      windSpeed: (wind['speed'] as num).toDouble(),
      icon: weather['icon'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['dt'] * 1000),
      isSunny: isSunny,
    );
  }
}
