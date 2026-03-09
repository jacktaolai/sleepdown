import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/weekly_courses_provider.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/repository.dart';

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
