import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_suggestion.dart';
import '../providers/weather_provider.dart';
import '../providers/activity_recommendation_provider.dart';

class ActivitySuggestionsScreen extends StatelessWidget {
  const ActivitySuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final recommendationProvider = Provider.of<ActivityRecommendationProvider>(
      context,
    );
    final currentWeather = weatherProvider.currentWeather;
    final isSunny = weatherProvider.isSunny;

    if (weatherProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (weatherProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(weatherProvider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                weatherProvider.fetchCurrentWeather();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (currentWeather == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('无法获取天气数据'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                weatherProvider.fetchCurrentWeather();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // Generate AI recommendation if not already loading or generated
    if (recommendationProvider.aiGeneratedSuggestion == null &&
        !recommendationProvider.isLoading &&
        recommendationProvider.errorMessage == null) {
      // Trigger generation of AI recommendation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        recommendationProvider.generateActivitySuggestion(currentWeather);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather Card
          Card(
            // elevation 已由 main.dart 中的 CardTheme 统一设置
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        weatherProvider.getWeatherIconUrl(currentWeather.icon),
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${currentWeather.temperature.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            currentWeather.condition,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '体感温度: ${currentWeather.feelsLike.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherDetail(
                        context,
                        Icons.water_drop,
                        '湿度',
                        '${currentWeather.humidity}%',
                      ),
                      _buildWeatherDetail(
                        context,
                        Icons.air,
                        '风速',
                        '${currentWeather.windSpeed} m/s',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // AI-generated activity suggestion
          Row(
            children: [
              Icon(
                isSunny
                    ? Icons.wb_sunny
                    : _getWeatherIcon(currentWeather.condition),
                color: isSunny ? Colors.amber : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                isSunny ? '今天是晴天！智能推荐活动' : '今天的智能推荐活动',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recommendationProvider.isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('正在生成活动建议...'),
                ],
              ),
            )
          else if (recommendationProvider.errorMessage != null)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(recommendationProvider.errorMessage!),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      recommendationProvider.generateActivitySuggestion(
                        currentWeather,
                      );
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            )
          else if (recommendationProvider.aiGeneratedSuggestion != null)
            _buildActivityCard(
              context,
              recommendationProvider.aiGeneratedSuggestion!,
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 28, color: colorScheme.secondary), // 调整图标大小和颜色
        const SizedBox(height: 8), // 增加间距
        Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)), // 突出数值
        const SizedBox(height: 2), // 调整间距
        Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.outline)), // 调整标签样式
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivitySuggestion activity) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // margin is handled by CardTheme in main.dart
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer, // Use theme color
                  foregroundColor: colorScheme.onPrimaryContainer, // Use theme color
                  radius: 24, // Slightly larger avatar
                  child: Icon(
                    _getActivityIcon(activity.iconName),
                    size: 28, // Adjust icon size
                  ),
                ),
                const SizedBox(width: 16),
                Expanded( // Allow title to wrap if needed
                  child: Text(
                    activity.title,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600), // Bolder title
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Adjust spacing
            Text(
              activity.description,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), // Subtle description color
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String iconName) {
    switch (iconName) {
      case 'walk':
        return Icons.directions_walk;
      case 'picnic':
        return Icons.park;
      case 'bike':
        return Icons.pedal_bike;
      case 'camera':
        return Icons.camera_alt;
      case 'yoga':
        return Icons.self_improvement;
      case 'indoor':
        return Icons.home;
      default:
        return Icons.sunny;
    }
  }

  IconData _getWeatherIcon(String condition) {
    if (condition == 'Clear') {
      return Icons.wb_sunny;
    } else if (condition == 'Clouds') {
      return Icons.cloud;
    } else if (condition == 'Rain') {
      return Icons.water_drop;
    } else if (condition == 'Snow') {
      return Icons.ac_unit;
    } else {
      return Icons.cloud;
    }
  }
}
