import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/course_table_provider.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/repository.dart';

void main() {
  group('CourseTableState', () {
    test('initial state should be empty', () {
      const state = CourseTableState();
      
      expect(state.table, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith should update specified fields', () {
      const state = CourseTableState();
      final now = DateTime.now();
      final table = CourseTable(
        id: 'test',
        name: '测试',
        semesterStartDate: now,
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );

      final newState = state.copyWith(table: table, isLoading: true);
      
      expect(newState.table, table);
      expect(newState.isLoading, true);
      expect(newState.error, isNull);
    });

    test('copyWith with error should update error', () {
      const state = CourseTableState();
      
      final newState = state.copyWith(error: 'test error');
      
      expect(newState.error, 'test error');
      expect(newState.table, isNull);
    });
  });

  group('CourseTableNotifier', () {
    test('should have initial loading state when created with null id', () {
      final notifier = CourseTableNotifier(_MockCourseTableRepository(), null);
      
      expect(notifier.state.isLoading, false);
      expect(notifier.state.table, isNull);
    });
  });
}

class _MockCourseTableRepository implements CourseTableRepository {
  @override
  Future<void> addCourseTable(CourseTable table) async {}

  @override
  Future<void> deleteCourseTable(String id) async {}

  @override
  Future<List<CourseTable>> getAllCourseTables() async => [];

  @override
  Future<CourseTable?> getCourseTableById(String id) async => null;

  @override
  Future<void> updateCourseTable(CourseTable table) async {}
}
