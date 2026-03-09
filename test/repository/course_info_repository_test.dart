import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/repository/course_info_repository.dart';
import 'package:sleepdown/models/course_info.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CourseInfoRepository', () {
    late DatabaseHelper dbHelper;
    late CourseInfoRepository repository;
    late String tableId;
    int testCounter = 0;

    setUp(() async {
      testCounter++;
      await Future.delayed(const Duration(milliseconds: 200));
      dbHelper = DatabaseHelper();

      // 创建课程表
      final db = await dbHelper.database;
      tableId = 'test-table-$testCounter-${DateTime.now().millisecondsSinceEpoch}';

      await db.insert('course_tables', {
        'id': tableId,
        'name': '2024春季学期',
        'semester_start_date': DateTime(2024, 2, 26).millisecondsSinceEpoch,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 清理之前的数据
      try {
        await db.delete('course_infos', where: 'course_table_id = ?', whereArgs: [tableId]);
      } catch (_) {}

      repository = CourseInfoRepositoryImpl(dbHelper);
    });

    tearDown(() async {
      try {
        await dbHelper.close();
      } catch (_) {}
    });

    String generateId(String prefix) {
      return '$prefix-$testCounter-${DateTime.now().millisecondsSinceEpoch}';
    }

    test('should add course info successfully', () async {
      final testId = generateId('test-info');
      final testInfo = CourseInfo(
        id: testId,
        courseTableId: tableId,
        name: '高等数学',
        credit: 4.0,
        colorValue: 0xFF3B82F6,
        note: '必修课',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseInfo(testInfo);
      final infos = await repository.getCourseInfosByTableId(tableId);
      expect(infos.length, equals(1));
      expect(infos.first.name, equals('高等数学'));
    });

    test('should get course info by id', () async {
      final testId = generateId('test-info');
      final testInfo = CourseInfo(
        id: testId,
        courseTableId: tableId,
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseInfo(testInfo);
      final info = await repository.getCourseInfoById(testId);
      expect(info, isNotNull);
      expect(info!.name, equals('高等数学'));
    });

    test('should return null for non-existent info', () async {
      final info = await repository.getCourseInfoById('non-existent');
      expect(info, isNull);
    });

    test('should update course info successfully', () async {
      final testId = generateId('test-info');
      final testInfo = CourseInfo(
        id: testId,
        courseTableId: tableId,
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseInfo(testInfo);

      final updated = testInfo.copyWith(name: '线性代数');
      await repository.updateCourseInfo(updated);

      final info = await repository.getCourseInfoById(testId);
      expect(info!.name, equals('线性代数'));
    });

    test('should delete course info successfully', () async {
      final testId = generateId('test-info');
      final testInfo = CourseInfo(
        id: testId,
        courseTableId: tableId,
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseInfo(testInfo);
      await repository.deleteCourseInfo(testId);

      final infos = await repository.getCourseInfosByTableId(tableId);
      expect(infos, isEmpty);
    });

    test('should get course infos sorted by name', () async {
      final testId1 = generateId('info-1');
      final testId2 = generateId('info-2');
      final testId3 = generateId('info-3');

      // Unicode排序: 线性代数(\u7EBF\u6027\u4EE3\u6570) < 高等数学(\u9AD8\u7B49\u6570\u5B66) < 大学英语(\u5927\u5B66\u82F1\u8BED)
      final info1 = CourseInfo(
        id: testId1,
        courseTableId: tableId,
        name: '线性代数',
        colorValue: 0xFFEF4444,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final info2 = CourseInfo(
        id: testId2,
        courseTableId: tableId,
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final info3 = CourseInfo(
        id: testId3,
        courseTableId: tableId,
        name: '大学英语',
        colorValue: 0xFF10B981,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseInfo(info1);
      await repository.addCourseInfo(info2);
      await repository.addCourseInfo(info3);

      final infos = await repository.getCourseInfosByTableId(tableId);
      expect(infos[0].name, equals('线性代数'));
      expect(infos[1].name, equals('高等数学'));
      expect(infos[2].name, equals('大学英语'));
    });
  });

  group('CourseInfoRepository - Aggregate Queries', () {
    late DatabaseHelper dbHelper;
    late CourseInfoRepository repository;
    late String tableId;
    int testCounter = 0;

    setUp(() async {
      testCounter++;
      await Future.delayed(const Duration(milliseconds: 200));
      dbHelper = DatabaseHelper();

      final db = await dbHelper.database;

      // 创建课程表
      tableId = 'test-table-$testCounter-${DateTime.now().millisecondsSinceEpoch}';
      await db.insert('course_tables', {
        'id': tableId,
        'name': '2024春季学期',
        'semester_start_date': DateTime(2024, 2, 26).millisecondsSinceEpoch,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 创建课程信息
      await db.insert('course_infos', {
        'id': 'info-1-$testCounter',
        'course_table_id': tableId,
        'name': '高等数学',
        'color_value': 0xFF3B82F6,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 创建课程安排
      await db.insert('course_schedules', {
        'id': 'schedule-1-$testCounter',
        'course_info_id': 'info-1-$testCounter',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'weeks': '[1,2,3]',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('course_schedules', {
        'id': 'schedule-2-$testCounter',
        'course_info_id': 'info-1-$testCounter',
        'teacher': '李老师',
        'location': '教学楼B202',
        'day_of_week': 2,
        'start_section': 3,
        'end_section': 4,
        'weeks': '[1,2,3]',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      repository = CourseInfoRepositoryImpl(dbHelper);
    });

    tearDown(() async {
      try {
        await dbHelper.close();
      } catch (_) {}
    });

    test('should get all teachers', () async {
      final teachers = await repository.getAllTeachers(tableId);
      expect(teachers, contains('张老师'));
      expect(teachers, contains('李老师'));
    });

    test('should get all locations', () async {
      final locations = await repository.getAllLocations(tableId);
      expect(locations, contains('教学楼A101'));
      expect(locations, contains('教学楼B202'));
    });

    test('should get all colors', () async {
      final colors = await repository.getAllColors(tableId);
      expect(colors, contains(0xFF3B82F6));
    });
  });
}
