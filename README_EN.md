[English Version](README_EN.md) | [中文版](README.md)

# mood_and_sun_journal
A Flutter application that combines mood journaling with weather information and activity suggestions.

## Project Overview
This project aims to help users record their daily moods, obtain weather information, and intelligently recommend activity suggestions based on mood and weather. It supports local data storage, geolocation, weather queries, personalized settings, and more.

## Main Features
- Mood recording and management
- Weather information retrieval and display
- Intelligent activity recommendations
- Browsing mood and activity history
- Personalized settings

## Directory Structure
```
lib/
  main.dart                  // Application entry point
  models/                    // Data models (e.g., mood_entry, weather, activity_suggestion)
  providers/                 // State management (e.g., mood_provider, weather_provider, activity_recommendation_provider)
  screens/                   // Feature pages (e.g., home_screen, mood_entry_screen, settings_screen, etc.)
  services/                  // Business services (e.g., database_helper, weather_service, location_service, settings_service)
```

## Environment Requirements
- Flutter 3.x or above
- Main dependencies:
  - provider
  - sqflite_common_ffi
  - path_provider
  - geolocator
  - For more, see pubspec.yaml

## How to Run
1. Install dependencies:
   ```
   flutter pub get
   ```
2. Run the project:
   ```
   flutter run
   ```

## Code Structure Description
- **models/**: Defines core data structures such as mood, weather, and activity suggestions.
- **providers/**: Responsible for state management, encapsulating business logic and data flow.
- **screens/**: UI and interaction logic for each feature page.
- **services/**: Service classes for database operations, location, weather APIs, settings management, etc.

## Contribution & Feedback
Suggestions and PRs to improve this project are welcome.

---

For Flutter development beginners, you may refer to:
- [Flutter Official Documentation](https://docs.flutter.dev/)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)