import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/course_schedule_provider.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/course_schedule_repository.dart';

void main() {
  group('CourseScheduleNotifier', () {
    test('initial state should be loading', () {
      final notifier = CourseScheduleNotifier(_MockCourseScheduleRepository(), 'info_1');
      
      expect(notifier.state.isLoading, true);
    });

    test('addSchedule should create and add schedule with sections', () async {
      final notifier = CourseScheduleNotifier(_MockCourseScheduleRepository(), 'info_1');
      
      final schedule = await notifier.addSchedule(
        teacher: '张教授',
        location: '教学楼A101',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 2, 3, 4, 5],
      );
      
      expect(schedule.teacher, '张教授');
      expect(schedule.location, '教学楼A101');
      expect(schedule.dayOfWeek, 1);
      expect(schedule.startSection, 1);
      expect(schedule.endSection, 2);
      expect(schedule.weeks, [1, 2, 3, 4, 5]);
      expect(schedule.courseInfoId, 'info_1');
    });

    test('addSchedule should create and add schedule with time', () async {
      final notifier = CourseScheduleNotifier(_MockCourseScheduleRepository(), 'info_1');
      
      final schedule = await notifier.addSchedule(
        teacher: '李教授',
        location: '实验楼B202',
        dayOfWeek: 3,
        startHour: 14,
        startMinute: 0,
        endHour: 15,
        endMinute: 30,
        weeks: [1, 3, 5, 7, 9],
      );
      
      expect(schedule.teacher, '李教授');
      expect(schedule.location, '实验楼B202');
      expect(schedule.dayOfWeek, 3);
      expect(schedule.startHour, 14);
      expect(schedule.startMinute, 0);
      expect(schedule.endHour, 15);
      expect(schedule.endMinute, 30);
      expect(schedule.weeks, [1, 3, 5, 7, 9]);
    });

    test('updateSchedule should update state', () async {
      final notifier = CourseScheduleNotifier(_MockCourseScheduleRepository(), 'info_1');
      
      final schedule = CourseSchedule(
        id: 'schedule_1',
        courseInfoId: 'info_1',
        teacher: '王教授',
        location: '图书馆C303',
        dayOfWeek: 5,
        startSection: 3,
        endSection: 4,
        weeks: [2, 4, 6, 8],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await notifier.updateSchedule(schedule);
      
      expect(notifier.state.isLoading, false);
    });

    test('deleteSchedule should update state', () async {
      final notifier = CourseScheduleNotifier(_MockCourseScheduleRepository(), 'info_1');
      
      await notifier.deleteSchedule('schedule_1');
      
      expect(notifier.state.isLoading, false);
    });
  });
}

class _MockCourseScheduleRepository implements CourseScheduleRepository {
  @override
  Future<List<CourseSchedule>> getSchedulesByCourseInfoId(String infoId) async => [];
  
  @override
  Future<List<CourseScheduleWithInfo>> getSchedulesByWeek(String tableId, int week) async => [];
  
  @override
  Future<void> addSchedule(CourseSchedule schedule) async {}
  
  @override
  Future<void> updateSchedule(CourseSchedule schedule) async {}
  
  @override
  Future<void> deleteSchedule(String id) async {}
}
