import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'mood_entry_screen.dart';
import 'activity_suggestions_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const MoodEntryScreen(),
    const ActivitySuggestionsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch weather data when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).fetchCurrentWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('心晴手账'),
        // backgroundColor, foregroundColor, elevation 已由 main.dart 中的 AppBarTheme 统一设置
        actions: [
          // Refresh weather data
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<WeatherProvider>(
                context,
                listen: false,
              ).fetchCurrentWeather();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('天气数据已更新')));
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: '今日心情'),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: '智能活动',
          ),
        ],
      ),
    );
  }
}
