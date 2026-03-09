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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// 配置数据库连接
  Future<void> _onConfigure(Database db) async {
    // 启用外键约束
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _upgradeToV2(db);
    }
  }

  /// 升级数据库到 v2
  Future<void> _upgradeToV2(Database db) async {
    // 创建 course_tables 表
    await db.execute('''
      CREATE TABLE course_tables (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        semester_start_date INTEGER NOT NULL,
        total_weeks INTEGER NOT NULL DEFAULT 18,
        time_schedule_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建 course_infos 表
    await db.execute('''
      CREATE TABLE course_infos (
        id TEXT PRIMARY KEY,
        course_table_id TEXT NOT NULL,
        name TEXT NOT NULL,
        credit REAL,
        color_value INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (course_table_id) REFERENCES course_tables(id) ON DELETE CASCADE
      )
    ''');

    // 创建 course_schedules 表
    await db.execute('''
      CREATE TABLE course_schedules (
        id TEXT PRIMARY KEY,
        course_info_id TEXT NOT NULL,
        teacher TEXT NOT NULL,
        location TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        start_section INTEGER,
        end_section INTEGER,
        start_hour INTEGER,
        start_minute INTEGER,
        end_hour INTEGER,
        end_minute INTEGER,
        weeks TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (course_info_id) REFERENCES course_infos(id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute(
        'CREATE INDEX idx_course_infos_table ON course_infos(course_table_id)');
    await db.execute(
        'CREATE INDEX idx_course_schedules_info ON course_schedules(course_info_id)');
    await db.execute(
        'CREATE INDEX idx_course_schedules_day ON course_schedules(day_of_week)');
  }

  /// 创建数据库表结构 (v2)
  Future<void> _onCreate(Database db, int version) async {
    // 创建 course_tables 表
    await db.execute('''
      CREATE TABLE course_tables (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        semester_start_date INTEGER NOT NULL,
        total_weeks INTEGER NOT NULL DEFAULT 18,
        time_schedule_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建 course_infos 表
    await db.execute('''
      CREATE TABLE course_infos (
        id TEXT PRIMARY KEY,
        course_table_id TEXT NOT NULL,
        name TEXT NOT NULL,
        credit REAL,
        color_value INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (course_table_id) REFERENCES course_tables(id) ON DELETE CASCADE
      )
    ''');

    // 创建 course_schedules 表
    await db.execute('''
      CREATE TABLE course_schedules (
        id TEXT PRIMARY KEY,
        course_info_id TEXT NOT NULL,
        teacher TEXT NOT NULL,
        location TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        start_section INTEGER,
        end_section INTEGER,
        start_hour INTEGER,
        start_minute INTEGER,
        end_hour INTEGER,
        end_minute INTEGER,
        weeks TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (course_info_id) REFERENCES course_infos(id) ON DELETE CASCADE
      )
    ''');

    // 保留旧版 courses 表用于数据迁移（暂时）
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

    // 创建 time_schedules 表
    await db.execute('''
      CREATE TABLE time_schedules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        slots TEXT NOT NULL,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 创建索引
    await db.execute(
        'CREATE INDEX idx_course_infos_table ON course_infos(course_table_id)');
    await db.execute(
        'CREATE INDEX idx_course_schedules_info ON course_schedules(course_info_id)');
    await db.execute(
        'CREATE INDEX idx_course_schedules_day ON course_schedules(day_of_week)');
    await db.execute('''
      CREATE INDEX idx_courses_day ON courses(day_of_week)
    ''');

    // 创建触发器确保只有一个默认作息时间
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
