import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../providers/weather_provider.dart';

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  int _selectedMoodScore = 3;
  String? _imagePath;
  bool _isLoading = false;
  MoodEntry? _todayEntry;

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayEntry() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateTime.now();
      final entry = await Provider.of<MoodProvider>(
        context,
        listen: false,
      ).getMoodEntryByDate(today);

      if (entry != null) {
        setState(() {
          _todayEntry = entry;
          _selectedMoodScore = entry.moodScore;
          _noteController.text = entry.note ?? '';
          _imagePath = entry.imagePath;
        });
      }
    } catch (e) {
      debugPrint('Error loading today\'s entry: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveMoodEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );
      final currentWeather = weatherProvider.currentWeather;

      final moodEntry = MoodEntry(
        id: _todayEntry?.id,
        date: DateTime.now(),
        moodScore: _selectedMoodScore,
        note: _noteController.text,
        imagePath: _imagePath,
        weatherCondition: currentWeather?.condition,
        temperature: currentWeather?.temperature,
      );

      final moodProvider = Provider.of<MoodProvider>(context, listen: false);

      if (_todayEntry != null) {
        await moodProvider.updateMoodEntry(moodEntry);
      } else {
        await moodProvider.addMoodEntry(moodEntry);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('心情已保存')));
      }
    } catch (e) {
      debugPrint('Error saving mood entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final currentWeather = weatherProvider.currentWeather;
    final isSunny = weatherProvider.isSunny;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Weather Section
            Card(
              // elevation 已由 main.dart 中的 CardTheme 统一设置
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('yyyy年MM月dd日').format(DateTime.now()),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (weatherProvider.isLoading)
                          const CircularProgressIndicator()
                        else if (weatherProvider.errorMessage != null)
                          Tooltip(
                            message: weatherProvider.errorMessage!,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '天气数据错误',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          )
                        else if (currentWeather != null)
                          Row(
                            children: [
                              Image.network(
                                weatherProvider.getWeatherIconUrl(
                                  currentWeather.icon,
                                ),
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${currentWeather.temperature.toStringAsFixed(1)}°C',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    currentWeather.condition,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (isSunny)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Chip(
                          backgroundColor: Colors.amber.shade100,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                color: Colors.amber.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '今天是晴天！',
                                style: TextStyle(color: Colors.amber.shade700),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mood Selection Section
            Text('今天的心情如何？', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodButton(1, '😢', '很糟'),
                _buildMoodButton(2, '😕', '不好'),
                _buildMoodButton(3, '😐', '一般'),
                _buildMoodButton(4, '🙂', '不错'),
                _buildMoodButton(5, '😄', '很棒'),
              ],
            ),

            const SizedBox(height: 24),

            // Note Section
            Text('记录一下今天的想法：', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '今天发生了什么？有什么感想？',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Image Section
            Text('添加图片：', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon( // 使用 OutlinedButton 视觉更轻量
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined), // 使用 outlined 图标
                  label: const Text('从相册选择'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.outline), // 明确边框颜色
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon( // 使用 OutlinedButton 视觉更轻量
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt_outlined), // 使用 outlined 图标
                  label: const Text('拍照'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.outline), // 明确边框颜色
                  ),
                ),
              ],
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 16),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _imagePath = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMoodEntry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('保存今日心情'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(int score, String emoji, String label) {
    final isSelected = _selectedMoodScore == score;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoodScore = score;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensure column takes minimum space
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200), // Add animation
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant, // Use theme colors
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: colorScheme.primaryContainer, width: 2)
                  : null,
              boxShadow: isSelected // Add subtle shadow when selected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      )
                    ]
                  : [],
            ),
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 24,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
