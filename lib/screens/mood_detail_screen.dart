import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';

class MoodDetailScreen extends StatelessWidget {
  final MoodEntry moodEntry;

  const MoodDetailScreen({super.key, required this.moodEntry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年MM月dd日').format(moodEntry.date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood and Weather Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _getMoodColor(moodEntry.moodScore),
                      child: Text(
                        _getMoodEmoji(moodEntry.moodScore),
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getMoodText(moodEntry.moodScore),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (moodEntry.weatherCondition != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _getWeatherIcon(moodEntry.weatherCondition!),
                                  color:
                                      _isSunnyWeather(
                                            moodEntry.weatherCondition!,
                                          )
                                          ? Colors.amber
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${moodEntry.weatherCondition}, ${moodEntry.temperature?.toStringAsFixed(1)}°C',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Note Section
            if (moodEntry.note != null && moodEntry.note!.isNotEmpty) ...[
              Text('记录：', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    moodEntry.note!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Image Section
            if (moodEntry.imagePath != null) ...[
              Text('图片：', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(moodEntry.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('删除记录'),
            content: const Text('确定要删除这条记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (result == true && context.mounted) {
      try {
        await Provider.of<MoodProvider>(
          context,
          listen: false,
        ).deleteMoodEntry(moodEntry.id!);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('记录已删除')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }

  Color _getMoodColor(int moodScore) {
    switch (moodScore) {
      case 1:
        return Colors.red.shade300;
      case 2:
        return Colors.orange.shade300;
      case 3:
        return Colors.yellow.shade300;
      case 4:
        return Colors.lightGreen.shade300;
      case 5:
        return Colors.green.shade300;
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(int moodScore) {
    switch (moodScore) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '❓';
    }
  }

  String _getMoodText(int moodScore) {
    switch (moodScore) {
      case 1:
        return '很糟';
      case 2:
        return '不好';
      case 3:
        return '一般';
      case 4:
        return '不错';
      case 5:
        return '很棒';
      default:
        return '未知';
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

  bool _isSunnyWeather(String condition) {
    return condition == 'Clear' ||
        (condition == 'Clouds' && condition.contains('few'));
  }
}
