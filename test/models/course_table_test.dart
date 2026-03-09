import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course_table.dart';

void main() {
  group('CourseTable', () {
    test('should create CourseTable with required fields', () {
      final now = DateTime.now();
      final table = CourseTable(
        id: 'test-id',
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );

      expect(table.id, equals('test-id'));
      expect(table.name, equals('2024春季学期'));
      expect(table.totalWeeks, equals(18));
      expect(table.timeScheduleId, equals('default'));
    });

    test('should create CourseTable with default totalWeeks', () {
      final now = DateTime.now();
      final table = CourseTable(
        id: 'test-id',
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );

      expect(table.totalWeeks, equals(18));
    });

    test('should convert to map correctly', () {
      final now = DateTime(2026, 1, 1, 0, 0, 0);
      final semesterDate = DateTime(2024, 2, 26);
      final table = CourseTable(
        id: 'test-id',
        name: '2024春季学期',
        semesterStartDate: semesterDate,
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );

      final map = table.toMap();

      expect(map['id'], equals('test-id'));
      expect(map['name'], equals('2024春季学期'));
      expect(map['total_weeks'], equals(18));
      expect(map['time_schedule_id'], equals('default'));
      expect(map['semester_start_date'], equals(semesterDate.millisecondsSinceEpoch));
    });

    test('should create from map correctly', () {
      final map = {
        'id': 'test-id',
        'name': '2024春季学期',
        'semester_start_date': 1708867200000,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': 1704067200000,
        'updated_at': 1704067200000,
      };

      final table = CourseTable.fromMap(map);

      expect(table.id, equals('test-id'));
      expect(table.name, equals('2024春季学期'));
      expect(table.totalWeeks, equals(18));
      expect(table.timeScheduleId, equals('default'));
    });

    test('should handle missing totalWeeks in map', () {
      final map = {
        'id': 'test-id',
        'name': '2024春季学期',
        'semester_start_date': 1708867200000,
        'time_schedule_id': 'default',
        'created_at': 1704067200000,
        'updated_at': 1704067200000,
      };

      final table = CourseTable.fromMap(map);

      expect(table.totalWeeks, equals(18));
    });

    test('should create copy with modified fields', () {
      final now = DateTime.now();
      final table = CourseTable(
        id: 'test-id',
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );

      final updated = table.copyWith(name: '2024秋季学期', totalWeeks: 20);

      expect(updated.name, equals('2024秋季学期'));
      expect(updated.totalWeeks, equals(20));
      expect(updated.id, equals(table.id));
    });

    test('should compare equality by id', () {
      final now = DateTime.now();
      final table1 = CourseTable(
        id: 'test-id',
        name: '2024春季学期',
        semesterStartDate: DateTime(2024, 2, 26),
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );

      final table2 = CourseTable(
        id: 'test-id',
        name: '不同的名字',
        semesterStartDate: DateTime(2024, 3, 1),
        timeScheduleId: 'other',
        createdAt: now,
        updatedAt: now,
      );

      expect(table1, equals(table2));
    });
  });
}
