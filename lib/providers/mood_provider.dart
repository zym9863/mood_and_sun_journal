import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../services/database_helper.dart';

class MoodProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;

  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;

  MoodProvider() {
    _loadMoodEntries();
  }

  Future<void> _loadMoodEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _moodEntries = await _dbHelper.getMoodEntries();
    } catch (e) {
      debugPrint('Error loading mood entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMoodEntry(MoodEntry moodEntry) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _dbHelper.insertMoodEntry(moodEntry);
      final newEntry = moodEntry.copyWith(id: id);
      _moodEntries.insert(0, newEntry); // Add to the beginning of the list
    } catch (e) {
      debugPrint('Error adding mood entry: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMoodEntry(MoodEntry moodEntry) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updateMoodEntry(moodEntry);
      final index = _moodEntries.indexWhere(
        (entry) => entry.id == moodEntry.id,
      );
      if (index != -1) {
        _moodEntries[index] = moodEntry;
      }
    } catch (e) {
      debugPrint('Error updating mood entry: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMoodEntry(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.deleteMoodEntry(id);
      _moodEntries.removeWhere((entry) => entry.id == id);
    } catch (e) {
      debugPrint('Error deleting mood entry: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async {
    try {
      return await _dbHelper.getMoodEntryByDate(date);
    } catch (e) {
      debugPrint('Error getting mood entry by date: $e');
      return null;
    }
  }

  Future<List<MoodEntry>> getMoodEntriesByMonth(int year, int month) async {
    try {
      return await _dbHelper.getMoodEntriesByMonth(year, month);
    } catch (e) {
      debugPrint('Error getting mood entries by month: $e');
      return [];
    }
  }

  Future<void> refreshMoodEntries() async {
    await _loadMoodEntries();
  }
}
