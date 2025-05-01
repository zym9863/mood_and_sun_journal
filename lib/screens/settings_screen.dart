import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    // Initialize the text field with the current API key
    final settingsService = Provider.of<SettingsService>(
      context,
      listen: false,
    );
    if (settingsService.apiKey != null) {
      _apiKeyController.text = settingsService.apiKey!;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() async {
    if (_formKey.currentState!.validate()) {
      final settingsService = Provider.of<SettingsService>(
        context,
        listen: false,
      );
      // Store the context before the async gap
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      await settingsService.saveApiKey(_apiKeyController.text.trim());

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('API密钥已保存')),
        );
        navigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        // backgroundColor and foregroundColor are handled by AppBarTheme in main.dart
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OpenWeatherMap API密钥',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  hintText: '输入您的API密钥',
                  border: const OutlineInputBorder(),
                  filled: true, // Add a subtle background fill
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust padding
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                obscureText: _isObscured,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入API密钥';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                '您可以在 OpenWeatherMap 网站上注册并获取免费的API密钥：',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse('https://openweathermap.org/api');
                  // Store the context before the async gap
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  if (!await launchUrl(url)) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('无法打开网页')),
                      );
                    }
                  }
                },
                child: Text(
                  'https://openweathermap.org/api',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveApiKey,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder( // Add rounded corners
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('保存'),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<SettingsService>(
                builder: (context, settingsService, child) {
                  if (settingsService.hasApiKey) {
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          // Store the context before the async gap
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );
                          await settingsService.clearApiKey();
                          if (mounted) {
                            _apiKeyController.clear();
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('API密钥已清除')),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Theme.of(context).colorScheme.error), // Use error color for destructive action
                          foregroundColor: Theme.of(context).colorScheme.error, // Use error color for text
                          shape: RoundedRectangleBorder( // Add rounded corners
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('清除API密钥'),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
