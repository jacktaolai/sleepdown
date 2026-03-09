import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sleepdown/database/db_helper.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = DatabaseHelper();
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('DatabaseHelper', () {
    test('should create database with all tables', () async {
      final db = await dbHelper.database;
      
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      expect(tableNames, contains('course_infos'));
      expect(tableNames, contains('course_schedules'));
      expect(tableNames, contains('course_tables'));
      expect(tableNames, contains('time_schedules'));
    });

    test('should create default time schedule', () async {
      final db = await dbHelper.database;
      
      final result = await db.query(
        'time_schedules',
        where: 'id = ?',
        whereArgs: ['default'],
      );
      
      expect(result, isNotEmpty);
      expect(result.first['name'], '默认作息');
    });

    test('should create indexes', () async {
      final db = await dbHelper.database;
      
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index'",
      );
      
      final indexNames = indexes.map((i) => i['name'] as String).toList();
      
      expect(indexNames, contains('idx_course_infos_table'));
      expect(indexNames, contains('idx_course_schedules_info'));
      expect(indexNames, contains('idx_course_schedules_day'));
    });

    test('should enable foreign keys', () async {
      final db = await dbHelper.database;
      
      await db.execute('PRAGMA foreign_keys = ON');
      final result = await db.rawQuery('PRAGMA foreign_keys');
      
      expect(result.first.values.first, 1);
    });
  });
}
