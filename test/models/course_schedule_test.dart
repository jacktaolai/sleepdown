import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/models.dart';

void main() {
  final now = DateTime.now();
  
  group('CourseSchedule', () {

    group('section mode', () {
      test('useTimeMode returns false when using section mode', () {
        final schedule = CourseSchedule(
          id: 'test_id',
          courseInfoId: 'info_id',
          teacher: '张三',
          location: 'A301',
          dayOfWeek: 1,
          startSection: 1,
          endSection: 2,
          weeks: [1, 2, 3],
          createdAt: now,
          updatedAt: now,
        );
        
        expect(schedule.useTimeMode, false);
      });

      test('sectionCount returns correct value', () {
        final schedule = CourseSchedule(
          id: 'test_id',
          courseInfoId: 'info_id',
          teacher: '张三',
          location: 'A301',
          dayOfWeek: 1,
          startSection: 2,
          endSection: 4,
          weeks: [1, 2, 3],
          createdAt: now,
          updatedAt: now,
        );
        
        expect(schedule.sectionCount, 3);
      });

      test('timeDisplayText returns section format', () {
        final schedule = CourseSchedule(
          id: 'test_id',
          courseInfoId: 'info_id',
          teacher: '张三',
          location: 'A301',
          dayOfWeek: 1,
          startSection: 3,
          endSection: 5,
          weeks: [1, 2, 3],
          createdAt: now,
          updatedAt: now,
        );
        
        expect(schedule.timeDisplayText, '第3-5节');
      });
    });

    group('time mode', () {
      test('useTimeMode returns true when using time mode', () {
        final schedule = CourseSchedule(
          id: 'test_id',
          courseInfoId: 'info_id',
          teacher: '张三',
          location: 'A301',
          dayOfWeek: 1,
          startHour: 14,
          startMinute: 30,
          endHour: 16,
          endMinute: 0,
          weeks: [1, 2, 3],
          createdAt: now,
          updatedAt: now,
        );
        
        expect(schedule.useTimeMode, true);
      });

      test('timeDisplayText returns time format', () {
        final schedule = CourseSchedule(
          id: 'test_id',
          courseInfoId: 'info_id',
          teacher: '张三',
          location: 'A301',
          dayOfWeek: 1,
          startHour: 14,
          startMinute: 30,
          endHour: 16,
          endMinute: 0,
          weeks: [1, 2, 3],
          createdAt: now,
          updatedAt: now,
        );
        
        expect(schedule.timeDisplayText, '14:30-16:00');
      });
    });

    group('weeks', () {
      test('isActiveInWeek returns true for active week', () {
        final schedule = CourseSchedule(
          id: 'test_id',
          courseInfoId: 'info_id',
          teacher: '张三',
          location: 'A301',
          dayOfWeek: 1,
          startSection: 1,
          endSection: 2,
          weeks: [1, 3, 5, 7],
          createdAt: now,
          updatedAt: now,
        );
        
        expect(schedule.isActiveInWeek(1), true);
        expect(schedule.isActiveInWeek(3), true);
        expect(schedule.isActiveInWeek(5), true);
      });

      test('isActiveInWeek returns false for inactive week', () {
        final schedule = CourseSchedule(
          id: 'test_id',
          courseInfoId: 'info_id',
          teacher: '张三',
          location: 'A301',
          dayOfWeek: 1,
          startSection: 1,
          endSection: 2,
          weeks: [1, 3, 5, 7],
          createdAt: now,
          updatedAt: now,
        );
        
        expect(schedule.isActiveInWeek(2), false);
        expect(schedule.isActiveInWeek(4), false);
        expect(schedule.isActiveInWeek(6), false);
      });
    });

    test('toMap and fromMap work correctly', () {
      final schedule = CourseSchedule(
        id: 'test_id',
        courseInfoId: 'info_id',
        teacher: '张三',
        location: 'A301',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 2, 3],
        createdAt: now,
        updatedAt: now,
      );
      
      final map = schedule.toMap();
      final restored = CourseSchedule.fromMap(map);
      
      expect(restored.id, schedule.id);
      expect(restored.courseInfoId, schedule.courseInfoId);
      expect(restored.teacher, schedule.teacher);
      expect(restored.location, schedule.location);
      expect(restored.dayOfWeek, schedule.dayOfWeek);
      expect(restored.weeks, schedule.weeks);
    });

    test('copyWith works correctly', () {
      final schedule = CourseSchedule(
        id: 'test_id',
        courseInfoId: 'info_id',
        teacher: '张三',
        location: 'A301',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 2, 3],
        createdAt: now,
        updatedAt: now,
      );
      
      final updated = schedule.copyWith(teacher: '李四', location: 'B201');
      
      expect(updated.id, 'test_id');
      expect(updated.teacher, '李四');
      expect(updated.location, 'B201');
    });
  });

  group('CourseScheduleWithInfo', () {
    test('can create instance with schedule and info', () {
      final localNow = DateTime.now();
      final schedule = CourseSchedule(
        id: 'schedule_id',
        courseInfoId: 'info_id',
        teacher: '张三',
        location: 'A301',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 2, 3],
        createdAt: localNow,
        updatedAt: localNow,
      );
      
      final info = CourseInfo(
        id: 'info_id',
        courseTableId: 'table_id',
        name: '数据结构',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );
      
      final withInfo = CourseScheduleWithInfo(
        schedule: schedule,
        info: info,
      );
      
      expect(withInfo.schedule.id, 'schedule_id');
      expect(withInfo.info.name, '数据结构');
    });
  });
}
