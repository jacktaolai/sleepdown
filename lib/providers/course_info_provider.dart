import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repository/course_info_repository.dart';
import 'database_helper_provider.dart';

class CourseInfoNotifier extends StateNotifier<AsyncValue<List<CourseInfo>>> {
  final CourseInfoRepository _repository;
  final String _courseTableId;

  CourseInfoNotifier(this._repository, this._courseTableId) : super(const AsyncValue.loading()) {
    _loadCourseInfos();
  }

  Future<void> _loadCourseInfos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getCourseInfosByTableId(_courseTableId));
  }

  Future<CourseInfo> addCourseInfo({
    required String name,
    double? credit,
    required int colorValue,
    String? note,
  }) async {
    final info = CourseInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseTableId: _courseTableId,
      name: name,
      credit: credit,
      colorValue: colorValue,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _repository.addCourseInfo(info);
    await _loadCourseInfos();
    return info;
  }

  Future<void> updateCourseInfo(CourseInfo info) async {
    await _repository.updateCourseInfo(info);
    await _loadCourseInfos();
  }

  Future<void> deleteCourseInfo(String id) async {
    await _repository.deleteCourseInfo(id);
    await _loadCourseInfos();
  }
}

final courseInfoProvider = StateNotifierProvider.family<CourseInfoNotifier, AsyncValue<List<CourseInfo>>, String>((ref, courseTableId) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CourseInfoNotifier(CourseInfoRepository(dbHelper), courseTableId);
});
