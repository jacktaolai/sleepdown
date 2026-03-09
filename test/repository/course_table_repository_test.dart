import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/repository/course_table_repository.dart';
import 'package:sleepdown/models/course_table.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CourseTableRepository', () {
    late DatabaseHelper dbHelper;
    late CourseTableRepository repository;
    int testCounter = 0;

    setUp(() async {
      testCounter++;
      await Future.delayed(const Duration(milliseconds: 200));
      dbHelper = DatabaseHelper();
      repository = CourseTableRepositoryImpl(dbHelper);

      // 清理之前的数据
      try {
        final db = await dbHelper.database;
        await db.delete('course_tables');
      } catch (_) {}
    });

    tearDown(() async {
      try {
        await dbHelper.close();
      } catch (_) {}
    });

    String generateId(String prefix) {
      return '${prefix}-${testCounter}-${DateTime.now().millisecondsSinceEpoch}';
    }

    test('should add course table successfully', () async {
      final testId = generateId('test-table');
      final testTable = CourseTable(
        id: testId,
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseTable(testTable);
      final tables = await repository.getAllCourseTables();
      expect(tables.length, equals(1));
      expect(tables.first.name, equals('2024春季学期'));
    });

    test('should get course table by id', () async {
      final testId = generateId('test-table');
      final testTable = CourseTable(
        id: testId,
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseTable(testTable);
      final table = await repository.getCourseTableById(testId);
      expect(table, isNotNull);
      expect(table!.name, equals('2024春季学期'));
    });

    test('should return null for non-existent table', () async {
      final table = await repository.getCourseTableById('non-existent');
      expect(table, isNull);
    });

    test('should update course table successfully', () async {
      final testId = generateId('test-table');
      final testTable = CourseTable(
        id: testId,
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseTable(testTable);

      final updated = testTable.copyWith(name: '2024秋季学期');
      await repository.updateCourseTable(updated);

      final table = await repository.getCourseTableById(testId);
      expect(table!.name, equals('2024秋季学期'));
    });

    test('should delete course table successfully', () async {
      final testId = generateId('test-table');
      final testTable = CourseTable(
        id: testId,
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseTable(testTable);
      await repository.deleteCourseTable(testId);

      final tables = await repository.getAllCourseTables();
      expect(tables, isEmpty);
    });

    test('should get current course table', () async {
      final testId = generateId('test-table');
      final testTable = CourseTable(
        id: testId,
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourseTable(testTable);
      final table = await repository.getCurrentCourseTable();
      expect(table, isNotNull);
      expect(table!.name, equals('2024春季学期'));
    });

    test('should return null when no tables exist', () async {
      final table = await repository.getCurrentCourseTable();
      expect(table, isNull);
    });

    test('should handle multiple course tables', () async {
      final testId1 = generateId('test-table-1');
      final testId2 = generateId('test-table-2');

      final table1 = CourseTable(
        id: testId1,
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final table2 = CourseTable(
        id: testId2,
        name: '2024秋季学期',
        semesterStartDate: DateTime(2024, 9, 1),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
      );

      await repository.addCourseTable(table1);
      await repository.addCourseTable(table2);

      final tables = await repository.getAllCourseTables();
      expect(tables.length, equals(2));
    });

    test('should get all course tables sorted by created_at DESC', () async {
      final testId1 = generateId('test-table-1');
      final testId2 = generateId('test-table-2');

      final table1 = CourseTable(
        id: testId1,
        name: '第一个课程表',
        semesterStartDate: DateTime(2024, 2, 26),
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final table2 = CourseTable(
        id: testId2,
        name: '第二个课程表',
        semesterStartDate: DateTime(2024, 9, 1),
        timeScheduleId: 'default',
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
      );

      await repository.addCourseTable(table1);
      await repository.addCourseTable(table2);

      final tables = await repository.getAllCourseTables();
      expect(tables.first.name, equals('第二个课程表'));
    });
  });
}
