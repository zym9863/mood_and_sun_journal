import 'dart:convert';

class MoodEntry {
  final int? id;
  final DateTime date;
  final int moodScore; // 1-5 scale
  final String? note;
  final String? imagePath;
  final String? weatherCondition;
  final double? temperature;

  MoodEntry({
    this.id,
    required this.date,
    required this.moodScore,
    this.note,
    this.imagePath,
    this.weatherCondition,
    this.temperature,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodScore': moodScore,
      'note': note,
      'imagePath': imagePath,
      'weatherCondition': weatherCondition,
      'temperature': temperature,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      moodScore: map['moodScore'],
      note: map['note'],
      imagePath: map['imagePath'],
      weatherCondition: map['weatherCondition'],
      temperature: map['temperature'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MoodEntry.fromJson(String source) => MoodEntry.fromMap(json.decode(source));

  MoodEntry copyWith({
    int? id,
    DateTime? date,
    int? moodScore,
    String? note,
    String? imagePath,
    String? weatherCondition,
    double? temperature,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodScore: moodScore ?? this.moodScore,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperature: temperature ?? this.temperature,
    );
  }
}
