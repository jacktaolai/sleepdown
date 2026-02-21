import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course.dart';

void main() {
  group('CourseNotifier Logic Tests', () {
    test('should create course list', () {
      final course = Course(
        id: '1',
        name: 'Math',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(course.name, equals('Math'));
      expect(course.dayOfWeek, equals(1));
    });

    test('should check if course is active in week', () {
      final course = Course(
        id: '1',
        name: 'Math',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(course.isActiveInWeek(1), isTrue);
      expect(course.isActiveInWeek(8), isTrue);
      expect(course.isActiveInWeek(16), isTrue);
      expect(course.isActiveInWeek(17), isFalse);
    });

    test('should filter by week correctly', () {
      final courses = [
        Course(
          id: '1',
          name: 'Math',
          dayOfWeek: 1,
          startSection: 1,
          endSection: 2,
          weekRanges: const [WeekRange(start: 1, end: 16)],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Course(
          id: '2',
          name: 'Physics',
          dayOfWeek: 1,
          startSection: 3,
          endSection: 4,
          weekRanges: const [WeekRange(start: 2, end: 16)],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final week1Courses = courses.where((c) => c.isActiveInWeek(1)).toList();
      expect(week1Courses.length, equals(1));
      expect(week1Courses.first.name, equals('Math'));

      final week2Courses = courses.where((c) => c.isActiveInWeek(2)).toList();
      expect(week2Courses.length, equals(2));
    });

    test('should filter by day correctly', () {
      final courses = [
        Course(
          id: '1',
          name: 'Math',
          dayOfWeek: 1,
          startSection: 1,
          endSection: 2,
          weekRanges: const [WeekRange(start: 1, end: 16)],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Course(
          id: '2',
          name: 'Physics',
          dayOfWeek: 2,
          startSection: 1,
          endSection: 2,
          weekRanges: const [WeekRange(start: 1, end: 16)],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final mondayCourses = courses.where((c) => c.dayOfWeek == 1).toList();
      expect(mondayCourses.length, equals(1));

      final tuesdayCourses = courses.where((c) => c.dayOfWeek == 2).toList();
      expect(tuesdayCourses.length, equals(1));
    });

    test('should detect conflict between courses', () {
      final course1 = Course(
        id: '1',
        name: 'Math',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final conflictCourse = Course(
        id: '2',
        name: 'Physics',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final hasConflict = course1.dayOfWeek == conflictCourse.dayOfWeek &&
          course1.startSection == conflictCourse.startSection &&
          course1.endSection == conflictCourse.endSection;

      expect(hasConflict, isTrue);
    });

    test('should calculate section count', () {
      final course = Course(
        id: '1',
        name: 'Math',
        dayOfWeek: 1,
        startSection: 2,
        endSection: 4,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(course.sectionCount, equals(3));
    });
  });

  group('Course Model', () {
    test('should copy with new name', () {
      final course = Course(
        id: '1',
        name: 'Math',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = course.copyWith(name: 'Advanced Math');
      expect(updated.name, equals('Advanced Math'));
      expect(updated.id, equals('1'));
    });

    test('should serialize and deserialize', () {
      final course = Course(
        id: '1',
        name: 'Math',
        teacher: 'Prof. Wang',
        location: 'Room 101',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        colorValue: 0xFF3B82F6,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final map = course.toMap();
      final restored = Course.fromMap(map);

      expect(restored.id, equals('1'));
      expect(restored.name, equals('Math'));
      expect(restored.teacher, equals('Prof. Wang'));
      expect(restored.dayOfWeek, equals(1));
    });
  });
}
