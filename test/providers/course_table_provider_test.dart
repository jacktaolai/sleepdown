import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/course_table_provider.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/course_table_repository.dart';

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

    test('copyWith should preserve existing values', () {
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
      
      final state = CourseTableState(table: table, isLoading: true);
      final newState = state.copyWith(isLoading: false);
      
      expect(newState.table, table);
      expect(newState.isLoading, false);
    });
  });

  group('CourseTableNotifier', () {
    test('should have initial empty state when created with null id', () {
      final notifier = CourseTableNotifier(_MockCourseTableRepository(), null);
      
      expect(notifier.state.isLoading, false);
      expect(notifier.state.table, isNull);
      expect(notifier.state.error, isNull);
    });

    test('switchCourseTable should update tableId', () async {
      final mockRepo = _MockCourseTableRepository();
      final notifier = CourseTableNotifier(mockRepo, null);
      
      await notifier.switchCourseTable('new_table_id');
      
      expect(notifier.state.isLoading, false);
    });

    test('updateCourseTable should update state', () async {
      final notifier = CourseTableNotifier(_MockCourseTableRepository(), 'table_1');
      
      final now = DateTime.now();
      final table = CourseTable(
        id: 'table_1',
        name: '更新后的课表',
        semesterStartDate: now,
        totalWeeks: 20,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );
      
      await notifier.updateCourseTable(table);
      
      expect(notifier.state.table, table);
      expect(notifier.state.table!.name, '更新后的课表');
      expect(notifier.state.table!.totalWeeks, 20);
    });

    test('addCourseTable should add and switch to new table', () async {
      final mockRepo = _MockCourseTableRepositoryWithTable();
      final notifier = CourseTableNotifier(mockRepo, null);
      
      final now = DateTime.now();
      final table = CourseTable(
        id: 'new_table',
        name: '新课表',
        semesterStartDate: now,
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );
      
      await notifier.addCourseTable(table);
      
      expect(notifier.state.table, isNotNull);
      expect(notifier.state.table!.id, 'new_table');
      expect(notifier.state.table!.name, '新课表');
    });

    test('deleteCourseTable should clear state if deleting current table', () async {
      final notifier = CourseTableNotifier(_MockCourseTableRepository(), 'table_1');
      
      await notifier.deleteCourseTable('table_1');
      
      expect(notifier.state.table, isNull);
    });

    test('deleteCourseTable should not clear state if deleting different table', () async {
      final notifier = CourseTableNotifier(_MockCourseTableRepository(), 'table_1');
      
      final now = DateTime.now();
      final table = CourseTable(
        id: 'table_1',
        name: '当前课表',
        semesterStartDate: now,
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );
      
      await notifier.updateCourseTable(table);
      await notifier.deleteCourseTable('other_table');
      
      expect(notifier.state.table, isNotNull);
      expect(notifier.state.table!.id, 'table_1');
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

class _MockCourseTableRepositoryWithTable implements CourseTableRepository {
  CourseTable? _table;

  @override
  Future<void> addCourseTable(CourseTable table) async {
    _table = table;
  }

  @override
  Future<void> deleteCourseTable(String id) async {
    if (_table?.id == id) {
      _table = null;
    }
  }

  @override
  Future<List<CourseTable>> getAllCourseTables() async {
    return _table != null ? [_table!] : [];
  }

  @override
  Future<CourseTable?> getCourseTableById(String id) async {
    return _table?.id == id ? _table : null;
  }

  @override
  Future<void> updateCourseTable(CourseTable table) async {
    _table = table;
  }
}
