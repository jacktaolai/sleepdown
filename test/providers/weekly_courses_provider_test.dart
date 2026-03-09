import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/weekly_courses_provider.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/course_schedule_repository.dart';

void main() {
  group('WeeklyCoursesNotifier', () {
    test('initial state should be loading', () {
      final notifier = WeeklyCoursesNotifier(
        _MockCourseScheduleRepository(),
        'test_table',
        1,
      );
      
      expect(notifier.state.isLoading, true);
    });

    test('loadCourses should update state', () async {
      final notifier = WeeklyCoursesNotifier(
        _MockCourseScheduleRepository(),
        'test_table',
        1,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(notifier.state.isLoading, false);
    });
  });

  group('CourseDetail', () {
    test('should contain info and schedules', () {
      final now = DateTime.now();
      final info = CourseInfo(
        id: 'info_1',
        courseTableId: 'table_1',
        name: '高等数学',
        credit: 4.0,
        colorValue: 0xFF2196F3,
        createdAt: now,
        updatedAt: now,
      );
      
      final schedules = [
        CourseSchedule(
          id: 'schedule_1',
          courseInfoId: 'info_1',
          teacher: '张教授',
          location: 'A101',
          dayOfWeek: 1,
          startSection: 1,
          endSection: 2,
          weeks: [1, 2, 3],
          createdAt: now,
          updatedAt: now,
        ),
      ];
      
      final detail = CourseDetail(info: info, schedules: schedules);
      
      expect(detail.info, info);
      expect(detail.schedules.length, 1);
      expect(detail.schedules.first.teacher, '张教授');
    });
  });
}

class _MockCourseScheduleRepository implements CourseScheduleRepository {
  @override
  Future<void> addSchedule(CourseSchedule schedule) async {}

  @override
  Future<void> deleteSchedule(String id) async {}

  @override
  Future<List<CourseSchedule>> getSchedulesByCourseInfoId(String infoId) async => [];

  @override
  Future<List<CourseScheduleWithInfo>> getSchedulesByWeek(String tableId, int week) async {
    return [];
  }

  @override
  Future<void> updateSchedule(CourseSchedule schedule) async {}
}
