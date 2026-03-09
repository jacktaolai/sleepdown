import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course_info.dart';
import 'package:sleepdown/models/course_schedule.dart';

void main() {
  group('CourseSchedule', () {
    late DateTime now;

    setUp(() {
      now = DateTime.now();
    });

    test('should create CourseSchedule with section mode', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      expect(schedule.id, equals('test-id'));
      expect(schedule.courseInfoId, equals('info-id'));
      expect(schedule.teacher, equals('张老师'));
      expect(schedule.location, equals('教学楼A101'));
      expect(schedule.dayOfWeek, equals(1));
      expect(schedule.startSection, equals(1));
      expect(schedule.endSection, equals(2));
      expect(schedule.useTimeMode, isFalse);
    });

    test('should create CourseSchedule with time mode', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3, 4],
        startHour: 14,
        startMinute: 30,
        endHour: 16,
        endMinute: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(schedule.startHour, equals(14));
      expect(schedule.startMinute, equals(30));
      expect(schedule.endHour, equals(16));
      expect(schedule.endMinute, equals(0));
      expect(schedule.useTimeMode, isTrue);
    });

    test('should calculate section count correctly', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 3,
        endSection: 5,
        createdAt: now,
        updatedAt: now,
      );

      expect(schedule.sectionCount, equals(3));
    });

    test('should return null section count for time mode', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startHour: 14,
        startMinute: 30,
        endHour: 16,
        endMinute: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(schedule.sectionCount, isNull);
    });

    test('should check isActiveInWeek correctly', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 8, 9, 10],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      expect(schedule.isActiveInWeek(1), isTrue);
      expect(schedule.isActiveInWeek(2), isTrue);
      expect(schedule.isActiveInWeek(5), isFalse);
      expect(schedule.isActiveInWeek(8), isTrue);
      expect(schedule.isActiveInWeek(9), isTrue);
      expect(schedule.isActiveInWeek(10), isTrue);
      expect(schedule.isActiveInWeek(11), isFalse);
    });

    test('should return correct time display text for section mode', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 3,
        endSection: 4,
        createdAt: now,
        updatedAt: now,
      );

      expect(schedule.timeDisplayText, equals('第3-4节'));
    });

    test('should return correct time display text for time mode', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startHour: 14,
        startMinute: 30,
        endHour: 16,
        endMinute: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(schedule.timeDisplayText, equals('14:30-16:00'));
    });

    test('should convert to map correctly', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 8, 9, 10],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final map = schedule.toMap();

      expect(map['id'], equals('test-id'));
      expect(map['course_info_id'], equals('info-id'));
      expect(map['teacher'], equals('张老师'));
      expect(map['location'], equals('教学楼A101'));
      expect(map['day_of_week'], equals(1));
      expect(map['start_section'], equals(1));
      expect(map['end_section'], equals(2));
      expect(map['weeks'], equals('[1,2,8,9,10]'));
    });

    test('should create from map correctly', () {
      final map = {
        'id': 'test-id',
        'course_info_id': 'info-id',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'start_hour': null,
        'start_minute': null,
        'end_hour': null,
        'end_minute': null,
        'weeks': '[1,2,8,9,10]',
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final schedule = CourseSchedule.fromMap(map);

      expect(schedule.id, equals('test-id'));
      expect(schedule.courseInfoId, equals('info-id'));
      expect(schedule.weeks, equals([1, 2, 8, 9, 10]));
      expect(schedule.startSection, equals(1));
      expect(schedule.endSection, equals(2));
    });

    test('should create copy with modified fields', () {
      final schedule = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final updated = schedule.copyWith(
        location: '教学楼B202',
        dayOfWeek: 2,
      );

      expect(updated.location, equals('教学楼B202'));
      expect(updated.dayOfWeek, equals(2));
      expect(updated.id, equals(schedule.id));
    });

    test('should compare equality by id', () {
      final schedule1 = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final schedule2 = CourseSchedule(
        id: 'test-id',
        courseInfoId: 'other-info',
        teacher: '李老师',
        location: '其他地点',
        dayOfWeek: 2,
        weeks: [4, 5],
        startSection: 3,
        endSection: 4,
        createdAt: now,
        updatedAt: now,
      );

      expect(schedule1, equals(schedule2));
    });
  });

  group('CourseScheduleWithInfo', () {
    test('should create CourseScheduleWithInfo', () {
      final now = DateTime.now();
      final schedule = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final info = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final withInfo = CourseScheduleWithInfo(
        schedule: schedule,
        info: info,
      );

      expect(withInfo.schedule.id, equals('schedule-id'));
      expect(withInfo.info.name, equals('高等数学'));
    });

    test('should compare equality by schedule id', () {
      final now = DateTime.now();
      final schedule1 = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final info1 = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final schedule2 = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'other-info',
        teacher: '李老师',
        location: '其他地点',
        dayOfWeek: 2,
        weeks: [4, 5],
        startSection: 3,
        endSection: 4,
        createdAt: now,
        updatedAt: now,
      );

      final info2 = CourseInfo(
        id: 'other-info',
        courseTableId: 'other-table',
        name: '线性代数',
        colorValue: 0xFF000000,
        createdAt: now,
        updatedAt: now,
      );

      final withInfo1 = CourseScheduleWithInfo(
        schedule: schedule1,
        info: info1,
      );

      final withInfo2 = CourseScheduleWithInfo(
        schedule: schedule2,
        info: info2,
      );

      expect(withInfo1, equals(withInfo2));
    });
  });

  group('CourseSchedule.createSectionMode', () {
    test('should create schedule with section mode', () {
      final schedule = CourseSchedule.createSectionMode(
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3, 4, 5],
        startSection: 1,
        endSection: 2,
      );

      expect(schedule.courseInfoId, equals('info-id'));
      expect(schedule.teacher, equals('张老师'));
      expect(schedule.startSection, equals(1));
      expect(schedule.endSection, equals(2));
      expect(schedule.useTimeMode, isFalse);
      expect(schedule.id, isNotEmpty);
    });
  });

  group('CourseSchedule.createTimeMode', () {
    test('should create schedule with time mode', () {
      final schedule = CourseSchedule.createTimeMode(
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3, 4],
        startHour: 14,
        startMinute: 30,
        endHour: 16,
        endMinute: 0,
      );

      expect(schedule.courseInfoId, equals('info-id'));
      expect(schedule.teacher, equals('张老师'));
      expect(schedule.startHour, equals(14));
      expect(schedule.startMinute, equals(30));
      expect(schedule.endHour, equals(16));
      expect(schedule.endMinute, equals(0));
      expect(schedule.useTimeMode, isTrue);
      expect(schedule.id, isNotEmpty);
    });
  });
}
