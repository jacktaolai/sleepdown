import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'sleepdown.db';
  static const int dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return await openDatabase(
      '$path/$dbName',
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE time_schedules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        slots TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE course_tables (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        semester_start_date INTEGER NOT NULL,
        total_weeks INTEGER NOT NULL DEFAULT 18,
        time_schedule_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (time_schedule_id) REFERENCES time_schedules(id)
      )
    ''');

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

    await db.execute(
        'CREATE INDEX idx_course_infos_table ON course_infos(course_table_id)');
    await db.execute(
        'CREATE INDEX idx_course_schedules_info ON course_schedules(course_info_id)');
    await db.execute(
        'CREATE INDEX idx_course_schedules_day ON course_schedules(day_of_week)');

    await _insertDefaultTimeSchedule(db);
  }

  Future<void> _insertDefaultTimeSchedule(Database db) async {
    final defaultSlots = [
      {'section': 1, 'startHour': 8, 'startMinute': 0, 'endHour': 8, 'endMinute': 45},
      {'section': 2, 'startHour': 8, 'startMinute': 50, 'endHour': 9, 'endMinute': 35},
      {'section': 3, 'startHour': 9, 'startMinute': 50, 'endHour': 10, 'endMinute': 35},
      {'section': 4, 'startHour': 10, 'startMinute': 40, 'endHour': 11, 'endMinute': 25},
      {'section': 5, 'startHour': 11, 'startMinute': 35, 'endHour': 12, 'endMinute': 20},
      {'section': 6, 'startHour': 14, 'startMinute': 0, 'endHour': 14, 'endMinute': 45},
      {'section': 7, 'startHour': 14, 'startMinute': 50, 'endHour': 15, 'endMinute': 35},
      {'section': 8, 'startHour': 15, 'startMinute': 50, 'endHour': 16, 'endMinute': 35},
      {'section': 9, 'startHour': 16, 'startMinute': 40, 'endHour': 17, 'endMinute': 25},
      {'section': 10, 'startHour': 19, 'startMinute': 0, 'endHour': 19, 'endMinute': 45},
      {'section': 11, 'startHour': 19, 'startMinute': 50, 'endHour': 20, 'endMinute': 35},
    ];

    await db.insert('time_schedules', {
      'id': 'default',
      'name': '默认作息',
      'slots': defaultSlots.toString(),
      'is_default': 1,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
