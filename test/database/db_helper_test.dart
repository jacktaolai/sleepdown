import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/utils/constants.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<void> cleanDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFile = p.join(dbPath, 'sleepdown.db');
    final file = File(dbFile);
    if (await file.exists()) {
      await file.delete();
    }
  }

  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      await cleanDatabase();
      dbHelper = DatabaseHelper();
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should create database successfully', () async {
      final db = await dbHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should create courses table', () async {
      final db = await dbHelper.database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='courses'",
      );
      expect(tables, isNotEmpty);
    });

    test('should create time_schedules table', () async {
      final db = await dbHelper.database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='time_schedules'",
      );
      expect(tables, isNotEmpty);
    });

    test('should insert default time schedule on creation', () async {
      final db = await dbHelper.database;
      final schedules = await db.query('time_schedules');
      expect(schedules, isNotEmpty);
      expect(schedules.first['name'], equals('默认作息时间'));
    });

    test('should have is_default = 1 for default schedule', () async {
      final db = await dbHelper.database;
      final schedules = await db.query(
        'time_schedules',
        where: 'is_default = ?',
        whereArgs: [1],
      );
      expect(schedules.length, equals(1));
    });

    test('should create index on day_of_week', () async {
      final db = await dbHelper.database;
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_courses_day'",
      );
      expect(indexes, isNotEmpty);
    });

    test('should return same database instance', () async {
      final db1 = await dbHelper.database;
      final db2 = await dbHelper.database;
      expect(identical(db1, db2), isTrue);
    });
  });

  group('DatabaseHelper - Courses CRUD', () {
    late DatabaseHelper dbHelper;
    late Database db;

    setUp(() async {
      await cleanDatabase();
      dbHelper = DatabaseHelper();
      db = await dbHelper.database;
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should insert a course', () async {
      await db.insert('courses', {
        'id': 'test-course-1',
        'name': '高等数学',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'week_ranges': jsonEncode([
          {'start': 1, 'end': 16, 'type': 0}
        ]),
        'color_value': 0xFF3B82F6,
        'note': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      final courses = await db.query('courses');
      expect(courses.length, equals(1));
      expect(courses.first['name'], equals('高等数学'));
    });

    test('should query courses by day', () async {
      await db.insert('courses', {
        'id': 'test-course-1',
        'name': '高等数学',
        'teacher': '',
        'location': '',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'week_ranges': '[]',
        'color_value': 0xFF3B82F6,
        'note': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      final courses = await db.query(
        'courses',
        where: 'day_of_week = ?',
        whereArgs: [1],
      );
      expect(courses.length, equals(1));
    });

    test('should update a course', () async {
      await db.insert('courses', {
        'id': 'test-course-1',
        'name': '高等数学',
        'teacher': '',
        'location': '',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'week_ranges': '[]',
        'color_value': 0xFF3B82F6,
        'note': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.update(
        'courses',
        {'name': '线性代数'},
        where: 'id = ?',
        whereArgs: ['test-course-1'],
      );

      final courses = await db.query('courses');
      expect(courses.first['name'], equals('线性代数'));
    });

    test('should delete a course', () async {
      await db.insert('courses', {
        'id': 'test-course-1',
        'name': '高等数学',
        'teacher': '',
        'location': '',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'week_ranges': '[]',
        'color_value': 0xFF3B82F6,
        'note': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.delete(
        'courses',
        where: 'id = ?',
        whereArgs: ['test-course-1'],
      );

      final courses = await db.query('courses');
      expect(courses, isEmpty);
    });
  });

  group('DatabaseHelper - TimeSchedules CRUD', () {
    late DatabaseHelper dbHelper;
    late Database db;

    setUp(() async {
      await cleanDatabase();
      dbHelper = DatabaseHelper();
      db = await dbHelper.database;
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should get default time schedule', () async {
      final schedules = await db.query(
        'time_schedules',
        where: 'is_default = ?',
        whereArgs: [1],
        limit: 1,
      );

      expect(schedules, isNotEmpty);
      expect(schedules.first['name'], equals('默认作息时间'));
    });

    test('should insert new time schedule', () async {
      await db.insert('time_schedules', {
        'id': 'custom-schedule',
        'name': '自定义作息',
        'slots': '[]',
        'is_default': 0,
      });

      final schedules = await db.query('time_schedules');
      expect(schedules.length, equals(2));
    });

    test('should update time schedule', () async {
      await db.update(
        'time_schedules',
        {'name': '更新后的作息'},
        where: 'id = ?',
        whereArgs: ['default'],
      );

      final schedule = await db.query(
        'time_schedules',
        where: 'id = ?',
        whereArgs: ['default'],
      );
      expect(schedule.first['name'], equals('更新后的作息'));
    });

    test('should delete time schedule', () async {
      await db.insert('time_schedules', {
        'id': 'to-delete',
        'name': '待删除',
        'slots': '[]',
        'is_default': 0,
      });

      await db.delete(
        'time_schedules',
        where: 'id = ?',
        whereArgs: ['to-delete'],
      );

      final schedules = await db.query('time_schedules');
      expect(schedules.any((s) => s['id'] == 'to-delete'), isFalse);
    });

    test('should auto clear is_default when setting new default', () async {
      await db.insert('time_schedules', {
        'id': 'new-default',
        'name': '新默认',
        'slots': '[]',
        'is_default': 1,
      });

      final oldDefault = await db.query(
        'time_schedules',
        where: 'id = ?',
        whereArgs: ['default'],
      );
      expect(oldDefault.first['is_default'], equals(0));

      final newDefault = await db.query(
        'time_schedules',
        where: 'id = ?',
        whereArgs: ['new-default'],
      );
      expect(newDefault.first['is_default'], equals(1));
    });
  });

  group('Constants', () {
    test('should have default time slots', () {
      expect(Constants.defaultTimeSlots, isNotEmpty);
      expect(Constants.defaultTimeSlots.length, equals(11));
    });

    test('should have course colors', () {
      expect(Constants.courseColors, isNotEmpty);
      expect(Constants.courseColors.length, equals(6));
    });

    test('should have max weeks', () {
      expect(Constants.maxWeeks, equals(25));
    });

    test('should have default total weeks', () {
      expect(Constants.defaultTotalWeeks, equals(18));
    });

    test('should have week day names', () {
      expect(Constants.weekDayNames.length, equals(7));
      expect(Constants.weekDayNames[0], equals('周一'));
      expect(Constants.weekDayNames[6], equals('周日'));
    });

    test('should get week day name correctly', () {
      expect(Constants.getWeekDayName(1), equals('周一'));
      expect(Constants.getWeekDayName(7), equals('周日'));
      expect(Constants.getWeekDayName(0), equals(''));
      expect(Constants.getWeekDayName(8), equals(''));
    });
  });
}
