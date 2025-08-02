import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/mood_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/activity_recommendation_provider.dart';
import 'services/settings_service.dart';
import 'services/database_helper.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for Windows
  DatabaseHelper.initDatabaseFactory();

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.init();

  runApp(MyApp(settingsService: settingsService));
}

class MyApp extends StatelessWidget {
  final SettingsService settingsService;

  const MyApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the settings service
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(settingsService: settingsService),
        ),
        ChangeNotifierProvider(create: (_) => ActivityRecommendationProvider()),
      ],
      child: MaterialApp(
        title: '心晴手账',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlueAccent, // 使用更柔和的种子颜色
            primary: Colors.lightBlueAccent[700], // 调整主色调
            secondary: Colors.amberAccent, // 调整次要色调
            brightness: Brightness.light, // 明确亮度
          ),
          appBarTheme: AppBarTheme( // 统一 AppBar 样式
            backgroundColor: Colors.lightBlueAccent[700], // AppBar 背景色
            foregroundColor: Colors.white, // AppBar 前景色（标题、图标）
            elevation: 0, // 移除 AppBar 阴影
            titleTextStyle: const TextStyle(
              fontFamily: 'Roboto', // 可以考虑更换字体
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData( // 统一底部导航栏样式
            selectedItemColor: Colors.lightBlueAccent[700],
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
          cardTheme: CardThemeData( // 统一卡片样式
            elevation: 2, // 调整卡片阴影
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // 增加圆角
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // 统一外边距
          ),
          useMaterial3: true,
          fontFamily: 'Roboto', // 全局字体，可以考虑更换
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
