import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/repository/course_repository.dart';
import 'package:sleepdown/models/course.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<void> cleanDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = p.join(dbPath, 'sleepdown.db');
      final file = File(dbFile);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Warning: Could not clean database: $e');
    }
  }

  tearDownAll(() async {
    await cleanDatabase();
  });

  group('CourseRepository', () {
    late DatabaseHelper dbHelper;
    late CourseRepository repository;

    setUp(() async {
      await cleanDatabase();
      await Future.delayed(const Duration(milliseconds: 100));
      SharedPreferences.setMockInitialValues({});
      dbHelper = DatabaseHelper();
      repository = CourseRepositoryImpl(dbHelper);
    });

    tearDown(() async {
      await repository.close();
      await dbHelper.close();
    });

    final testCourse = Course(
      id: 'test-course-1',
      name: '高等数学',
      teacher: '张老师',
      location: '教学楼A101',
      dayOfWeek: 1,
      startSection: 1,
      endSection: 2,
      weekRanges: const [
        WeekRange(start: 1, end: 16, type: WeekType.all),
      ],
      colorValue: 0xFF3B82F6,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('should add course successfully', () async {
      await repository.addCourse(testCourse);
      final courses = await repository.getAllCourses();
      expect(courses.length, equals(1));
      expect(courses.first.name, equals('高等数学'));
    });

    test('should get course by id', () async {
      await repository.addCourse(testCourse);
      final course = await repository.getCourseById('test-course-1');
      expect(course, isNotNull);
      expect(course!.name, equals('高等数学'));
    });

    test('should return null for non-existent course', () async {
      final course = await repository.getCourseById('non-existent');
      expect(course, isNull);
    });

    test('should update course successfully', () async {
      await repository.addCourse(testCourse);
      
      final updated = testCourse.copyWith(name: '线性代数');
      await repository.updateCourse(updated);
      
      final course = await repository.getCourseById('test-course-1');
      expect(course!.name, equals('线性代数'));
    });

    test('should delete course successfully', () async {
      await repository.addCourse(testCourse);
      await repository.deleteCourse('test-course-1');
      
      final courses = await repository.getAllCourses();
      expect(courses, isEmpty);
    });

    test('should get courses by week', () async {
      await repository.addCourse(testCourse);
      
      final week1Courses = await repository.getCoursesByWeek(1);
      expect(week1Courses.length, equals(1));
      
      final week17Courses = await repository.getCoursesByWeek(17);
      expect(week17Courses, isEmpty);
    });

    test('should get courses by day', () async {
      await repository.addCourse(testCourse);
      
      final mondayCourses = await repository.getCoursesByDay(1);
      expect(mondayCourses.length, equals(1));
      
      final tuesdayCourses = await repository.getCoursesByDay(2);
      expect(tuesdayCourses, isEmpty);
    });

    test('should handle multiple courses', () async {
      final course1 = testCourse;
      final course2 = Course(
        id: 'test-course-2',
        name: '大学英语',
        dayOfWeek: 2,
        startSection: 3,
        endSection: 4,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.odd),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourse(course1);
      await repository.addCourse(course2);

      final courses = await repository.getAllCourses();
      expect(courses.length, equals(2));
    });

    test('should filter courses by week correctly', () async {
      final oddWeekCourse = Course(
        id: 'odd-course',
        name: '体育课',
        dayOfWeek: 3,
        startSection: 6,
        endSection: 7,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.odd),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.addCourse(oddWeekCourse);

      final week1Courses = await repository.getCoursesByWeek(1);
      expect(week1Courses.length, equals(1));

      final week2Courses = await repository.getCoursesByWeek(2);
      expect(week2Courses, isEmpty);
    });
  });
}
