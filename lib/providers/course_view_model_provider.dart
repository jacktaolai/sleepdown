import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_view_model.dart';
import '../models/course_table.dart';
import '../models/course_info.dart';
import '../models/course_schedule.dart';
import '../repository/course_table_repository.dart';
import '../repository/course_info_repository.dart';
import '../repository/course_schedule_repository.dart';
import '../database/db_helper.dart';

/// 数据库帮助类 Provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// 课程表仓库 Provider
final courseTableRepositoryProvider = Provider<CourseTableRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CourseTableRepositoryImpl(dbHelper);
});

/// 课程信息仓库 Provider
final courseInfoRepositoryProvider = Provider<CourseInfoRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CourseInfoRepositoryImpl(dbHelper);
});

/// 课程安排仓库 Provider
final courseScheduleRepositoryProvider = Provider<CourseScheduleRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CourseScheduleRepositoryImpl(dbHelper);
});

/// 当前课程表 Provider
final currentCourseTableProvider = FutureProvider<CourseTable?>((ref) async {
  final repository = ref.watch(courseTableRepositoryProvider);
  return repository.getCurrentCourseTable();
});

/// 所有课程表列表 Provider
final courseTableListProvider = FutureProvider<List<CourseTable>>((ref) async {
  final repository = ref.watch(courseTableRepositoryProvider);
  return repository.getAllCourseTables();
});

/// 当前课程表下的课程视图模型列表 Provider
final courseViewModelsProvider = FutureProvider<List<CourseViewModel>>((ref) async {
  final table = await ref.watch(currentCourseTableProvider.future);
  if (table == null) return [];

  final repository = ref.watch(courseScheduleRepositoryProvider);
  return repository.getAllCourseViewModels(table.id);
});

/// 指定周次的课程视图模型列表 Provider
final courseViewModelsByWeekProvider = FutureProvider.family<List<CourseViewModel>, int>((ref, week) async {
  final table = await ref.watch(currentCourseTableProvider.future);
  if (table == null) return [];

  final repository = ref.watch(courseScheduleRepositoryProvider);
  return repository.getCourseViewModelsByWeek(table.id, week);
});

/// 课程数据管理 Notifier
class CourseViewModelNotifier extends StateNotifier<AsyncValue<List<CourseViewModel>>> {
  final CourseScheduleRepository _scheduleRepository;
  final CourseInfoRepository _infoRepository;
  final CourseTableRepository _tableRepository;

  CourseViewModelNotifier(
    this._scheduleRepository,
    this._infoRepository,
    this._tableRepository,
  ) : super(const AsyncValue.loading()) {
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      state = const AsyncValue.loading();

      final table = await _tableRepository.getCurrentCourseTable();
      if (table == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final courses = await _scheduleRepository.getAllCourseViewModels(table.id);
      state = AsyncValue.data(courses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadCourses();
  }

  List<CourseViewModel> getCoursesByWeek(int week) {
    return state.whenOrNull(
          data: (courses) => courses.where((c) => c.isActiveInWeek(week)).toList(),
        ) ??
        [];
  }

  List<CourseViewModel> getCoursesByDay(int week, int dayOfWeek) {
    return getCoursesByWeek(week)
        .where((c) => c.dayOfWeek == dayOfWeek)
        .toList();
  }

  Future<void> addCourse(CourseInfo info, CourseSchedule schedule) async {
    await _infoRepository.addCourseInfo(info);
    await _scheduleRepository.addSchedule(schedule);
    await _loadCourses();
  }

  Future<void> updateCourseInfo(CourseInfo info) async {
    await _infoRepository.updateCourseInfo(info);
    await _loadCourses();
  }

  Future<void> updateSchedule(CourseSchedule schedule) async {
    await _scheduleRepository.updateSchedule(schedule);
    await _loadCourses();
  }

  Future<void> deleteCourse(String scheduleId) async {
    await _scheduleRepository.deleteSchedule(scheduleId);
    await _loadCourses();
  }

  CourseViewModel? getCourseById(String id) {
    return state.whenOrNull(
          data: (courses) {
            try {
              return courses.firstWhere((c) => c.id == id);
            } catch (_) {
              return null;
            }
          },
        );
  }
}

/// 课程视图模型 Notifier Provider
final courseViewModelNotifierProvider =
    StateNotifierProvider<CourseViewModelNotifier, AsyncValue<List<CourseViewModel>>>((ref) {
  final scheduleRepo = ref.watch(courseScheduleRepositoryProvider);
  final infoRepo = ref.watch(courseInfoRepositoryProvider);
  final tableRepo = ref.watch(courseTableRepositoryProvider);
  return CourseViewModelNotifier(scheduleRepo, infoRepo, tableRepo);
});
