import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course.dart';

void main() {
  group('WeekRange', () {
    test('should contain week within range with all type', () {
      const range = WeekRange(start: 1, end: 16, type: WeekType.all);
      
      expect(range.contains(1), isTrue);
      expect(range.contains(8), isTrue);
      expect(range.contains(16), isTrue);
      expect(range.contains(0), isFalse);
      expect(range.contains(17), isFalse);
    });

    test('should contain only odd weeks with odd type', () {
      const range = WeekRange(start: 1, end: 16, type: WeekType.odd);
      
      expect(range.contains(1), isTrue);
      expect(range.contains(2), isFalse);
      expect(range.contains(3), isTrue);
      expect(range.contains(4), isFalse);
      expect(range.contains(15), isTrue);
      expect(range.contains(16), isFalse);
    });

    test('should contain only even weeks with even type', () {
      const range = WeekRange(start: 1, end: 16, type: WeekType.even);
      
      expect(range.contains(1), isFalse);
      expect(range.contains(2), isTrue);
      expect(range.contains(3), isFalse);
      expect(range.contains(4), isTrue);
      expect(range.contains(15), isFalse);
      expect(range.contains(16), isTrue);
    });

    test('should serialize and deserialize correctly', () {
      const range = WeekRange(start: 1, end: 16, type: WeekType.odd);
      
      final json = range.toJson();
      final fromJson = WeekRange.fromJson(json);
      
      expect(fromJson.start, equals(range.start));
      expect(fromJson.end, equals(range.end));
      expect(fromJson.type, equals(range.type));
    });

    test('should format toString correctly', () {
      expect(
        const WeekRange(start: 1, end: 16, type: WeekType.all).toString(),
        equals('1-16'),
      );
      expect(
        const WeekRange(start: 1, end: 16, type: WeekType.odd).toString(),
        equals('1-16单'),
      );
      expect(
        const WeekRange(start: 1, end: 16, type: WeekType.even).toString(),
        equals('1-16双'),
      );
      expect(
        const WeekRange(start: 5, end: 5, type: WeekType.all).toString(),
        equals('5'),
      );
    });
  });

  group('Course', () {
    final testCourse = Course(
      id: 'test-id',
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

    test('should calculate section count correctly', () {
      expect(testCourse.sectionCount, equals(2));
    });

    test('should check if active in week correctly', () {
      expect(testCourse.isActiveInWeek(1), isTrue);
      expect(testCourse.isActiveInWeek(8), isTrue);
      expect(testCourse.isActiveInWeek(16), isTrue);
      expect(testCourse.isActiveInWeek(17), isFalse);
    });

    test('should serialize and deserialize correctly', () {
      final map = testCourse.toMap();
      final fromMap = Course.fromMap(map);
      
      expect(fromMap.id, equals(testCourse.id));
      expect(fromMap.name, equals(testCourse.name));
      expect(fromMap.teacher, equals(testCourse.teacher));
      expect(fromMap.location, equals(testCourse.location));
      expect(fromMap.dayOfWeek, equals(testCourse.dayOfWeek));
      expect(fromMap.startSection, equals(testCourse.startSection));
      expect(fromMap.endSection, equals(testCourse.endSection));
      expect(fromMap.weekRanges.length, equals(testCourse.weekRanges.length));
    });

    test('should copy with new values', () {
      final updated = testCourse.copyWith(name: '线性代数');
      
      expect(updated.id, equals(testCourse.id));
      expect(updated.name, equals('线性代数'));
      expect(updated.teacher, equals(testCourse.teacher));
    });

    test('should handle multiple week ranges', () {
      final course = Course(
        id: 'test-id-2',
        name: '体育课',
        dayOfWeek: 3,
        startSection: 6,
        endSection: 7,
        weekRanges: const [
          WeekRange(start: 1, end: 8, type: WeekType.odd),
          WeekRange(start: 9, end: 16, type: WeekType.even),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(course.isActiveInWeek(1), isTrue);
      expect(course.isActiveInWeek(2), isFalse);
      expect(course.isActiveInWeek(10), isTrue);
      expect(course.isActiveInWeek(9), isFalse);
    });
  });
}
