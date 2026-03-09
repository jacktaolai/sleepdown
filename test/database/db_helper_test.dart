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

  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;
    int testCounter = 0;

    setUp(() async {
      testCounter++;
      await Future.delayed(const Duration(milliseconds: 200));
      dbHelper = DatabaseHelper();
    });

    tearDown(() async {
      try {
        await dbHelper.close();
      } catch (_) {}
    });

    test('should create database successfully', () async {
      final db = await dbHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    // ========== v2 新表测试 ==========

    test('should create course_tables table (v2)', () async {
      final db = await dbHelper.database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='course_tables'",
      );
      expect(tables, isNotEmpty);
    });

    test('should create course_infos table (v2)', () async {
      final db = await dbHelper.database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='course_infos'",
      );
      expect(tables, isNotEmpty);
    });

    test('should create course_schedules table (v2)', () async {
      final db = await dbHelper.database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='course_schedules'",
      );
      expect(tables, isNotEmpty);
    });

    test('should create indexes for v2 tables', () async {
      final db = await dbHelper.database;
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_course_%'",
      );
      expect(indexes.length, greaterThanOrEqualTo(3));
    });

    test('should return same database instance', () async {
      final db1 = await dbHelper.database;
      final db2 = await dbHelper.database;
      expect(identical(db1, db2), isTrue);
    });
  });

  group('DatabaseHelper - CourseTables CRUD (v2)', () {
    late DatabaseHelper dbHelper;
    late Database db;
    int testCounter = 0;

    setUp(() async {
      testCounter++;
      await Future.delayed(const Duration(milliseconds: 200));
      dbHelper = DatabaseHelper();
      db = await dbHelper.database;
    });

    tearDown(() async {
      try {
        await dbHelper.close();
      } catch (_) {}
    });

    test('should insert a course_table', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_tables', {
        'id': 'table-$testCounter',
        'name': '2024春季学期',
        'semester_start_date': now,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': now,
        'updated_at': now,
      });

      final tables = await db.query('course_tables');
      expect(tables.length, equals(1));
      expect(tables.first['name'], equals('2024春季学期'));
    });

    test('should query course_tables by id', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_tables', {
        'id': 'table-$testCounter',
        'name': '2024春季学期',
        'semester_start_date': now,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': now,
        'updated_at': now,
      });

      final tables = await db.query(
        'course_tables',
        where: 'id = ?',
        whereArgs: ['table-$testCounter'],
      );
      expect(tables.length, equals(1));
    });

    test('should update a course_table', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_tables', {
        'id': 'table-$testCounter',
        'name': '2024春季学期',
        'semester_start_date': now,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': now,
        'updated_at': now,
      });

      await db.update(
        'course_tables',
        {'name': '2024秋季学期'},
        where: 'id = ?',
        whereArgs: ['table-$testCounter'],
      );

      final tables = await db.query('course_tables');
      expect(tables.first['name'], equals('2024秋季学期'));
    });

    test('should delete a course_table', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_tables', {
        'id': 'table-$testCounter',
        'name': '2024春季学期',
        'semester_start_date': now,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': now,
        'updated_at': now,
      });

      await db.delete(
        'course_tables',
        where: 'id = ?',
        whereArgs: ['table-$testCounter'],
      );

      final tables = await db.query('course_tables');
      expect(tables, isEmpty);
    });
  });

  group('DatabaseHelper - CourseInfos CRUD (v2)', () {
    late DatabaseHelper dbHelper;
    late Database db;
    int testCounter = 0;

    setUp(() async {
      testCounter++;
      await Future.delayed(const Duration(milliseconds: 200));
      dbHelper = DatabaseHelper();
      db = await dbHelper.database;

      // 创建课程表
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_tables', {
        'id': 'table-$testCounter',
        'name': '2024春季学期',
        'semester_start_date': now,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': now,
        'updated_at': now,
      });
    });

    tearDown(() async {
      try {
        await dbHelper.close();
      } catch (_) {}
    });

    test('should insert a course_info', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_infos', {
        'id': 'info-$testCounter',
        'course_table_id': 'table-$testCounter',
        'name': '高等数学',
        'credit': 4.0,
        'color_value': 0xFF3B82F6,
        'note': '必修课',
        'created_at': now,
        'updated_at': now,
      });

      final infos = await db.query('course_infos');
      expect(infos.length, equals(1));
      expect(infos.first['name'], equals('高等数学'));
    });

    test('should query course_infos by course_table_id', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_infos', {
        'id': 'info-$testCounter',
        'course_table_id': 'table-$testCounter',
        'name': '高等数学',
        'color_value': 0xFF3B82F6,
        'created_at': now,
        'updated_at': now,
      });

      final infos = await db.query(
        'course_infos',
        where: 'course_table_id = ?',
        whereArgs: ['table-$testCounter'],
      );
      expect(infos.length, equals(1));
    });

    test('should update a course_info', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_infos', {
        'id': 'info-$testCounter',
        'course_table_id': 'table-$testCounter',
        'name': '高等数学',
        'color_value': 0xFF3B82F6,
        'created_at': now,
        'updated_at': now,
      });

      await db.update(
        'course_infos',
        {'name': '线性代数'},
        where: 'id = ?',
        whereArgs: ['info-$testCounter'],
      );

      final infos = await db.query('course_infos');
      expect(infos.first['name'], equals('线性代数'));
    });

    test('should delete a course_info', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_infos', {
        'id': 'info-$testCounter',
        'course_table_id': 'table-$testCounter',
        'name': '高等数学',
        'color_value': 0xFF3B82F6,
        'created_at': now,
        'updated_at': now,
      });

      await db.delete(
        'course_infos',
        where: 'id = ?',
        whereArgs: ['info-$testCounter'],
      );

      final infos = await db.query('course_infos');
      expect(infos, isEmpty);
    });
  });

  group('DatabaseHelper - CourseSchedules CRUD (v2)', () {
    late DatabaseHelper dbHelper;
    late Database db;
    int testCounter = 0;

    setUp(() async {
      testCounter++;
      await Future.delayed(const Duration(milliseconds: 200));
      dbHelper = DatabaseHelper();
      db = await dbHelper.database;

      // 创建课程表和课程信息
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_tables', {
        'id': 'table-$testCounter',
        'name': '2024春季学期',
        'semester_start_date': now,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': now,
        'updated_at': now,
      });

      await db.insert('course_infos', {
        'id': 'info-$testCounter',
        'course_table_id': 'table-$testCounter',
        'name': '高等数学',
        'color_value': 0xFF3B82F6,
        'created_at': now,
        'updated_at': now,
      });
    });

    tearDown(() async {
      try {
        await dbHelper.close();
      } catch (_) {}
    });

    test('should insert a course_schedule (section mode)', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_schedules', {
        'id': 'schedule-$testCounter',
        'course_info_id': 'info-$testCounter',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'start_hour': null,
        'start_minute': null,
        'end_hour': null,
        'end_minute': null,
        'weeks': '[1,2,3,4,5]',
        'created_at': now,
        'updated_at': now,
      });

      final schedules = await db.query('course_schedules');
      expect(schedules.length, equals(1));
      expect(schedules.first['teacher'], equals('张老师'));
    });

    test('should insert a course_schedule (time mode)', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_schedules', {
        'id': 'schedule-time-$testCounter',
        'course_info_id': 'info-$testCounter',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': null,
        'end_section': null,
        'start_hour': 14,
        'start_minute': 30,
        'end_hour': 16,
        'end_minute': 0,
        'weeks': '[1,2,3,4]',
        'created_at': now,
        'updated_at': now,
      });

      final schedules = await db.query('course_schedules');
      expect(schedules.length, equals(1));
      expect(schedules.first['start_hour'], equals(14));
    });

    test('should query course_schedules by course_info_id', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_schedules', {
        'id': 'schedule-$testCounter',
        'course_info_id': 'info-$testCounter',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'weeks': '[1,2,3]',
        'created_at': now,
        'updated_at': now,
      });

      final schedules = await db.query(
        'course_schedules',
        where: 'course_info_id = ?',
        whereArgs: ['info-$testCounter'],
      );
      expect(schedules.length, equals(1));
    });

    test('should update a course_schedule', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_schedules', {
        'id': 'schedule-$testCounter',
        'course_info_id': 'info-$testCounter',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'weeks': '[1,2,3]',
        'created_at': now,
        'updated_at': now,
      });

      await db.update(
        'course_schedules',
        {'location': '教学楼B202'},
        where: 'id = ?',
        whereArgs: ['schedule-$testCounter'],
      );

      final schedules = await db.query('course_schedules');
      expect(schedules.first['location'], equals('教学楼B202'));
    });

    test('should delete a course_schedule', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_schedules', {
        'id': 'schedule-$testCounter',
        'course_info_id': 'info-$testCounter',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'weeks': '[1,2,3]',
        'created_at': now,
        'updated_at': now,
      });

      await db.delete(
        'course_schedules',
        where: 'id = ?',
        whereArgs: ['schedule-$testCounter'],
      );

      final schedules = await db.query('course_schedules');
      expect(schedules, isEmpty);
    });

    test('should cascade delete course_schedules when course_info deleted', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('course_schedules', {
        'id': 'schedule-$testCounter',
        'course_info_id': 'info-$testCounter',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'weeks': '[1,2,3]',
        'created_at': now,
        'updated_at': now,
      });

      // 删除课程信息
      await db.delete(
        'course_infos',
        where: 'id = ?',
        whereArgs: ['info-$testCounter'],
      );

      // 课程安排应该被级联删除
      final schedules = await db.query('course_schedules');
      expect(schedules, isEmpty);
    });
  });

  group('DatabaseHelper - TimeSchedules CRUD', () {
    late DatabaseHelper dbHelper;
    late Database db;
    int testCounter = 0;

    setUp(() async {
      testCounter++;
      await Future.delayed(const Duration(milliseconds: 200));
      dbHelper = DatabaseHelper();
      db = await dbHelper.database;
    });

    tearDown(() async {
      try {
        await dbHelper.close();
      } catch (_) {}
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
        'id': 'custom-schedule-$testCounter',
        'name': '自定义作息',
        'slots': '[]',
        'is_default': 0,
      });

      final schedules = await db.query('time_schedules');
      expect(schedules.length, equals(2)); // 默认 + 自定义
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
        'id': 'to-delete-$testCounter',
        'name': '待删除',
        'slots': '[]',
        'is_default': 0,
      });

      await db.delete(
        'time_schedules',
        where: 'id = ?',
        whereArgs: ['to-delete-$testCounter'],
      );

      final schedules = await db.query('time_schedules');
      expect(schedules.any((s) => s['id'] == 'to-delete-$testCounter'), isFalse);
    });

    test('should auto clear is_default when setting new default', () async {
      await db.insert('time_schedules', {
        'id': 'new-default-$testCounter',
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
        whereArgs: ['new-default-$testCounter'],
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
