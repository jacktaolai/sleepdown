import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repository/course_schedule_repository.dart';
import 'database_helper_provider.dart';

class CourseScheduleNotifier extends StateNotifier<AsyncValue<List<CourseSchedule>>> {
  final CourseScheduleRepository _repository;
  final String _courseInfoId;

  CourseScheduleNotifier(this._repository, this._courseInfoId) : super(const AsyncValue.loading()) {
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getSchedulesByCourseInfoId(_courseInfoId));
  }

  Future<CourseSchedule> addSchedule({
    required String teacher,
    required String location,
    required int dayOfWeek,
    int? startSection,
    int? endSection,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    required List<int> weeks,
  }) async {
    final schedule = CourseSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseInfoId: _courseInfoId,
      teacher: teacher,
      location: location,
      dayOfWeek: dayOfWeek,
      startSection: startSection,
      endSection: endSection,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      weeks: weeks,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _repository.addSchedule(schedule);
    await _loadSchedules();
    return schedule;
  }

  Future<void> updateSchedule(CourseSchedule schedule) async {
    await _repository.updateSchedule(schedule);
    await _loadSchedules();
  }

  Future<void> deleteSchedule(String id) async {
    await _repository.deleteSchedule(id);
    await _loadSchedules();
  }
}

final courseScheduleProvider = StateNotifierProvider.family<CourseScheduleNotifier, AsyncValue<List<CourseSchedule>>, String>((ref, courseInfoId) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CourseScheduleNotifier(CourseScheduleRepository(dbHelper), courseInfoId);
});
