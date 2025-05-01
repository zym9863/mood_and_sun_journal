// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mood_and_sun_journal/services/settings_service.dart';
import 'package:mood_and_sun_journal/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Create a mock settings service for testing
    final settingsService = SettingsService();

    // We need to initialize the settings service before using it
    await settingsService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(settingsService: settingsService));

    // Verify that the app builds without errors
    expect(find.text('心晴手账'), findsOneWidget);
  });
}
