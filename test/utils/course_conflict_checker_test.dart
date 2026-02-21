import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course.dart';
import 'package:sleepdown/utils/course_conflict_checker.dart';

void main() {
  group('CourseConflictChecker', () {
    late Course existingCourse;

    setUp(() {
      existingCourse = Course(
        id: 'existing-1',
        name: '高等数学',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.all),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
    });

    test('should detect conflict with same day and overlapping sections', () {
      final newCourse = Course(
        id: 'new-1',
        name: '线性代数',
        dayOfWeek: 1,
        startSection: 2,
        endSection: 3,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.all),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final conflicts = CourseConflictChecker.checkConflict(newCourse, [existingCourse]);
      expect(conflicts.length, equals(1));
    });

    test('should not detect conflict on different days', () {
      final newCourse = Course(
        id: 'new-1',
        name: '线性代数',
        dayOfWeek: 2,
        startSection: 1,
        endSection: 2,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.all),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final conflicts = CourseConflictChecker.checkConflict(newCourse, [existingCourse]);
      expect(conflicts, isEmpty);
    });

    test('should not detect conflict with non-overlapping sections', () {
      final newCourse = Course(
        id: 'new-1',
        name: '线性代数',
        dayOfWeek: 1,
        startSection: 3,
        endSection: 4,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.all),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final conflicts = CourseConflictChecker.checkConflict(newCourse, [existingCourse]);
      expect(conflicts, isEmpty);
    });

    test('should not detect conflict with different weeks', () {
      final newCourse = Course(
        id: 'new-1',
        name: '线性代数',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.odd),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final evenWeekCourse = Course(
        id: 'existing-2',
        name: '高等数学',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.even),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final conflicts = CourseConflictChecker.checkConflict(newCourse, [evenWeekCourse]);
      expect(conflicts, isEmpty);
    });

    test('should not detect conflict with same course', () {
      final conflicts = CourseConflictChecker.checkConflict(existingCourse, [existingCourse]);
      expect(conflicts, isEmpty);
    });

    test('should check hasConflict correctly', () {
      final conflictingCourse = Course(
        id: 'new-1',
        name: '线性代数',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.all),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(
        CourseConflictChecker.hasConflict(conflictingCourse, [existingCourse]),
        isTrue,
      );

      final nonConflictingCourse = Course(
        id: 'new-2',
        name: '线性代数',
        dayOfWeek: 2,
        startSection: 1,
        endSection: 2,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.all),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(
        CourseConflictChecker.hasConflict(nonConflictingCourse, [existingCourse]),
        isFalse,
      );
    });

    test('should check conflicts for specific week', () {
      final oddWeekCourse = Course(
        id: 'odd-1',
        name: '体育课',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.odd),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final newCourse = Course(
        id: 'new-1',
        name: '新课程',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [
          WeekRange(start: 1, end: 16, type: WeekType.all),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(
        CourseConflictChecker.checkConflictsForWeek(newCourse, [oddWeekCourse], 1).length,
        equals(1),
      );
      expect(
        CourseConflictChecker.checkConflictsForWeek(newCourse, [oddWeekCourse], 2).length,
        equals(0),
      );
    });
  });
}
