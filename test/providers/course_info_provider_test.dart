import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/course_info_provider.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/course_info_repository.dart';

void main() {
  group('CourseInfoNotifier', () {
    test('initial state should be loading', () {
      final notifier = CourseInfoNotifier(_MockCourseInfoRepository(), 'table_1');
      
      expect(notifier.state.isLoading, true);
    });

    test('addCourseInfo should create and add course info', () async {
      final notifier = CourseInfoNotifier(_MockCourseInfoRepository(), 'table_1');
      
      final info = await notifier.addCourseInfo(
        name: '高等数学',
        credit: 4.0,
        colorValue: 0xFF2196F3,
        note: '必修课',
      );
      
      expect(info.name, '高等数学');
      expect(info.credit, 4.0);
      expect(info.colorValue, 0xFF2196F3);
      expect(info.note, '必修课');
      expect(info.courseTableId, 'table_1');
    });

    test('updateCourseInfo should update state', () async {
      final notifier = CourseInfoNotifier(_MockCourseInfoRepository(), 'table_1');
      
      final info = CourseInfo(
        id: 'info_1',
        courseTableId: 'table_1',
        name: '线性代数',
        credit: 3.0,
        colorValue: 0xFF4CAF50,
        note: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await notifier.updateCourseInfo(info);
      
      expect(notifier.state.isLoading, false);
    });

    test('deleteCourseInfo should update state', () async {
      final notifier = CourseInfoNotifier(_MockCourseInfoRepository(), 'table_1');
      
      await notifier.deleteCourseInfo('info_1');
      
      expect(notifier.state.isLoading, false);
    });
  });
}

class _MockCourseInfoRepository implements CourseInfoRepository {
  @override
  Future<List<CourseInfo>> getCourseInfosByTableId(String tableId) async => [];
  
  @override
  Future<CourseInfo?> getCourseInfoById(String id) async => null;
  
  @override
  Future<void> addCourseInfo(CourseInfo info) async {}
  
  @override
  Future<void> updateCourseInfo(CourseInfo info) async {}
  
  @override
  Future<void> deleteCourseInfo(String id) async {}
  
  @override
  Future<List<String>> getAllTeachers(String tableId) async => [];
  
  @override
  Future<List<String>> getAllLocations(String tableId) async => [];
  
  @override
  Future<List<int>> getAllColors(String tableId) async => [];
}
