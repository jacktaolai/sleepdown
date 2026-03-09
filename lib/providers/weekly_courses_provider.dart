import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repository/course_schedule_repository.dart';
import '../repository/course_info_repository.dart';
import 'database_helper_provider.dart';
import 'course_table_provider.dart';

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

final weeklyCoursesProvider = FutureProvider.family<List<CourseScheduleWithInfo>, int>((ref, week) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return [];
  
  final dbHelper = ref.read(databaseHelperProvider);
  final repository = CourseScheduleRepository(dbHelper);
  return repository.getSchedulesByWeek(tableState.table!.id, week);
});

final dailyCoursesProvider = Provider.family<Map<int, List<CourseScheduleWithInfo>>, int>((ref, week) {
  final weeklyCourses = ref.watch(weeklyCoursesProvider(week));
  
  final result = <int, List<CourseScheduleWithInfo>>{};
  for (int day = 1; day <= 7; day++) {
    result[day] = [];
  }
  
  weeklyCourses.whenData((courses) {
    for (final item in courses) {
      final day = item.schedule.dayOfWeek;
      if (day >= 1 && day <= 7) {
        result[day]!.add(item);
      }
    }
  });
  
  return result;
});

class CourseDetail {
  final CourseInfo info;
  final List<CourseSchedule> schedules;
  
  const CourseDetail({
    required this.info,
    required this.schedules,
  });
}

final courseDetailProvider = FutureProvider.family<CourseDetail?, String>((ref, courseInfoId) async {
  final dbHelper = ref.read(databaseHelperProvider);
  final infoRepo = CourseInfoRepository(dbHelper);
  final scheduleRepo = CourseScheduleRepository(dbHelper);
  
  final info = await infoRepo.getCourseInfoById(courseInfoId);
  if (info == null) return null;
  
  final schedules = await scheduleRepo.getSchedulesByCourseInfoId(courseInfoId);
  
  return CourseDetail(info: info, schedules: schedules);
});

final allTeachersProvider = FutureProvider<List<String>>((ref) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return [];
  
  final dbHelper = ref.read(databaseHelperProvider);
  final repository = CourseInfoRepository(dbHelper);
  return repository.getAllTeachers(tableState.table!.id);
});

final allLocationsProvider = FutureProvider<List<String>>((ref) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return [];
  
  final dbHelper = ref.read(databaseHelperProvider);
  final repository = CourseInfoRepository(dbHelper);
  return repository.getAllLocations(tableState.table!.id);
});

final allColorsProvider = FutureProvider<List<int>>((ref) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return [];
  
  final dbHelper = ref.read(databaseHelperProvider);
  final repository = CourseInfoRepository(dbHelper);
  return repository.getAllColors(tableState.table!.id);
});
