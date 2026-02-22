import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/course.dart';
import '../../models/app_settings.dart';
import '../../models/time_schedule.dart';
import '../../repository/settings_repository.dart';
import '../../repository/course_repository.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/schedule_grid.dart';
import '../widgets/week_calendar_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double timeColumnWidth = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.watch(currentWeekProvider);
    final courses = ref.watch(courseListProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 计算列宽：与底部课程网格一致
              final columnWidth = (constraints.maxWidth - timeColumnWidth) / 7;

              return Column(
                children: [
                  _buildHeader(context, ref, currentWeek),
                  WeekCalendarStrip(
                    columnWidth: columnWidth,
                    timeColumnWidth: timeColumnWidth,
                  ),
                  Expanded(
                    child: ScheduleGrid(
                      courses: courses,
                      currentWeek: currentWeek,
                      columnWidth: columnWidth,
                      timeColumnWidth: timeColumnWidth,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int currentWeek) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month}/${now.day}';
    
    // Check if semester ended (mock logic or from settings)
    final totalWeeks = ref.watch(settingsProvider).totalWeeks;
    final isSemesterEnded = currentWeek > totalWeeks;
    final weekStatus = isSemesterEnded ? '学期已结束' : '进行中';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '第$currentWeek周',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· $weekStatus',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(context, Icons.calendar_month_outlined, () {
                // Show week picker
              }),
              _buildIconButton(context, Icons.download_outlined, () {
                // Download schedule
              }),
              _buildIconButton(context, Icons.share_outlined, () {
                // Share schedule
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: AppTheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        hoverColor: AppTheme.onSurfaceVariant.withValues(alpha: 0.08),
        highlightColor: AppTheme.onSurfaceVariant.withValues(alpha: 0.12),
      ),
    );
  }
}

// ============== Mock Repository for Preview ==============

class MockSettingsRepository implements SettingsRepository {
  final AppSettings _settings;

  MockSettingsRepository({AppSettings? settings})
      : _settings = settings ?? const AppSettings();

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> updateSettings(AppSettings settings) async {}

  @override
  Future<TimeSchedule?> getTimeSchedule() async => null;

  @override
  Future<TimeSchedule?> getTimeScheduleById(String id) async => null;

  @override
  Future<List<TimeSchedule>> getAllTimeSchedules() async => [];

  @override
  Future<void> updateTimeSchedule(TimeSchedule schedule) async {}

  @override
  Future<void> addTimeSchedule(TimeSchedule schedule) async {}

  @override
  Future<void> deleteTimeSchedule(String id) async {}

  @override
  Future<void> setDefaultTimeSchedule(String id) async {}

  @override
  Future<void> close() async {}
}

class MockCourseRepository implements CourseRepository {
  final List<Course> _courses;

  MockCourseRepository({List<Course>? courses}) : _courses = courses ?? [];

  @override
  Future<List<Course>> getAllCourses() async => _courses;

  @override
  Future<List<Course>> getCoursesByWeek(int week) async {
    return _courses.where((course) => course.isActiveInWeek(week)).toList();
  }

  @override
  Future<List<Course>> getCoursesByDay(int dayOfWeek) async {
    return _courses.where((course) => course.dayOfWeek == dayOfWeek).toList();
  }

  @override
  Future<Course?> getCourseById(String id) async {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addCourse(Course course) async {}

  @override
  Future<void> updateCourse(Course course) async {}

  @override
  Future<void> deleteCourse(String id) async {}

  @override
  Future<void> close() async {}
}

// ============== Widget Preview Annotations ==============

/// 预览: HomeScreen - 完整课程表页面
@Preview(
  name: 'HomeScreen - 完整页面',
  group: 'HomeScreen',
  size: Size(390, 844),
)
Widget homeScreenPreview() {
  final courses = [
    Course(
      id: '1',
      name: '数据结构',
      teacher: '张三',
      location: 'A301',
      dayOfWeek: 1,
      startSection: 1,
      endSection: 2,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Course(
      id: '2',
      name: '算法设计',
      teacher: '李四',
      location: 'B205',
      dayOfWeek: 2,
      startSection: 3,
      endSection: 4,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Course(
      id: '3',
      name: '操作系统',
      teacher: '王五',
      location: 'C402',
      dayOfWeek: 3,
      startSection: 5,
      endSection: 6,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Course(
      id: '4',
      name: '计算机网络',
      teacher: '赵六',
      location: 'D101',
      dayOfWeek: 5,
      startSection: 7,
      endSection: 8,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Course(
      id: '5',
      name: '体育',
      teacher: '钱老师',
      location: '操场',
      dayOfWeek: 4,
      startSection: 9,
      endSection: 10,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final settings = AppSettings(
    semesterStartDate: DateTime(2026, 2, 16),
    totalWeeks: 20,
  );

  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(MockSettingsRepository(settings: settings)),
      courseRepositoryProvider.overrideWithValue(MockCourseRepository(courses: courses)),
    ],
    child: MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: const HomeScreen(),
    ),
  );
}

/// 预览: HomeScreen - 暗色模式
@Preview(
  name: 'HomeScreen - 暗色模式',
  group: 'HomeScreen',
  size: Size(390, 844),
  brightness: Brightness.dark,
)
Widget homeScreenDarkPreview() {
  final courses = [
    Course(
      id: '1',
      name: '数据结构',
      teacher: '张三',
      location: 'A301',
      dayOfWeek: 1,
      startSection: 1,
      endSection: 2,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Course(
      id: '2',
      name: '算法设计',
      teacher: '李四',
      location: 'B205',
      dayOfWeek: 2,
      startSection: 3,
      endSection: 4,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final settings = AppSettings(
    semesterStartDate: DateTime(2026, 2, 16),
    totalWeeks: 20,
  );

  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(MockSettingsRepository(settings: settings)),
      courseRepositoryProvider.overrideWithValue(MockCourseRepository(courses: courses)),
    ],
    child: MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    ),
  );
}
