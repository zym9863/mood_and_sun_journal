import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/mood_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Initialize database factory for Windows
  static void initDatabaseFactory() {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI for Windows and Linux
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'mood_journal.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        moodScore INTEGER NOT NULL,
        note TEXT,
        imagePath TEXT,
        weatherCondition TEXT,
        temperature REAL
      )
    ''');
  }

  // CRUD operations for MoodEntry

  Future<int> insertMoodEntry(MoodEntry moodEntry) async {
    Database db = await database;
    return await db.insert('mood_entries', moodEntry.toMap());
  }

  Future<List<MoodEntry>> getMoodEntries() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'mood_entries',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return MoodEntry.fromMap(maps[i]);
    });
  }

  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async {
    Database db = await database;
    String dateString = date.toIso8601String().split('T')[0];

    List<Map<String, dynamic>> maps = await db.query(
      'mood_entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
    );

    if (maps.isNotEmpty) {
      return MoodEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMoodEntry(MoodEntry moodEntry) async {
    Database db = await database;
    return await db.update(
      'mood_entries',
      moodEntry.toMap(),
      where: 'id = ?',
      whereArgs: [moodEntry.id],
    );
  }

  Future<int> deleteMoodEntry(int id) async {
    Database db = await database;
    return await db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MoodEntry>> getMoodEntriesByMonth(int year, int month) async {
    Database db = await database;

    // Create date range for the month
    DateTime startDate = DateTime(year, month, 1);
    DateTime endDate = DateTime(year, month + 1, 0); // Last day of the month

    List<Map<String, dynamic>> maps = await db.query(
      'mood_entries',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return MoodEntry.fromMap(maps[i]);
    });
  }
}
