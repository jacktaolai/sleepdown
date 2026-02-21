import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sleepdown.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        teacher TEXT,
        location TEXT,
        day_of_week INTEGER NOT NULL,
        start_section INTEGER NOT NULL,
        end_section INTEGER NOT NULL,
        week_ranges TEXT NOT NULL,
        color_value INTEGER,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE time_schedules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        slots TEXT NOT NULL,
        is_default INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_courses_day ON courses(day_of_week)
    ''');

    await db.execute('''
      CREATE TRIGGER ensure_single_default_schedule
      AFTER UPDATE OF is_default ON time_schedules
      WHEN NEW.is_default = 1
      BEGIN
        UPDATE time_schedules SET is_default = 0 
        WHERE id != NEW.id AND is_default = 1;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER ensure_single_default_on_insert
      AFTER INSERT ON time_schedules
      WHEN NEW.is_default = 1
      BEGIN
        UPDATE time_schedules SET is_default = 0 
        WHERE id != NEW.id AND is_default = 1;
      END
    ''');

    await _insertDefaultTimeSchedule(db);
  }

  Future<void> _insertDefaultTimeSchedule(Database db) async {
    final defaultSlots = Constants.defaultTimeSlots;
    final slotsJson = defaultSlots
        .map((s) => {
              'section': s.section,
              'startHour': s.startHour,
              'startMinute': s.startMinute,
              'endHour': s.endHour,
              'endMinute': s.endMinute,
            })
        .toList();

    await db.insert('time_schedules', {
      'id': 'default',
      'name': '默认作息时间',
      'slots': jsonEncode(slotsJson),
      'is_default': 1,
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
