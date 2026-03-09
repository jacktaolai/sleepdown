import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repository/repository.dart';

class WeeklyCoursesNotifier extends StateNotifier<AsyncValue<List<CourseScheduleWithInfo>>> {
  final CourseScheduleRepository _repository;
  final String _tableId;

  WeeklyCoursesNotifier(this._repository, this._tableId, int initialWeek) 
      : super(const AsyncValue.loading()) {
    loadCourses(initialWeek);
  }

  Future<void> loadCourses(int week) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getSchedulesByWeek(_tableId, week));
  }
}
