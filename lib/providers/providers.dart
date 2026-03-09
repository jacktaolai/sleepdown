import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repository/repository.dart';
import '../database/db_helper.dart';
import 'settings_provider.dart';
import 'course_table_provider.dart';
import 'time_schedule_provider.dart';
import 'weekly_courses_provider.dart';

export 'settings_provider.dart';
export 'course_table_provider.dart';
export 'time_schedule_provider.dart';
export 'weekly_courses_provider.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final courseTableProvider = StateNotifierProvider<CourseTableNotifier, CourseTableState>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  final settings = ref.watch(settingsProvider);
  return CourseTableNotifier(CourseTableRepository(dbHelper), settings.currentCourseTableId);
});

final timeScheduleProvider = FutureProvider<TimeSchedule?>((ref) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return null;
  
  final dbHelper = ref.read(databaseHelperProvider);
  final repository = TimeScheduleRepository(dbHelper);
  return repository.getTimeScheduleById(tableState.table!.timeScheduleId);
});

final currentWeekProvider = StateNotifierProvider<CurrentWeekNotifier, int>((ref) {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return CurrentWeekNotifier(DateTime.now(), 18);
  
  return CurrentWeekNotifier(
    tableState.table!.semesterStartDate,
    tableState.table!.totalWeeks,
  );
});

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

class CourseDetail {
  final CourseInfo info;
  final List<CourseSchedule> schedules;
  
  const CourseDetail({
    required this.info,
    required this.schedules,
  });
}
