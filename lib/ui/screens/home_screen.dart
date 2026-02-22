import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/course.dart';
import '../../models/app_settings.dart';
import '../../models/time_schedule.dart';
import '../../repository/settings_repository.dart';
import '../../repository/course_repository.dart';
import '../../providers/providers.dart';
import '../widgets/schedule_grid.dart';
import '../widgets/week_calendar_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double timeColumnWidth = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentWeek = ref.watch(currentWeekProvider);
    final courses = ref.watch(courseListProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columnWidth = (constraints.maxWidth - timeColumnWidth) / 7;

              return Column(
                children: [
                  _buildHeader(context, ref, currentWeek, colorScheme),
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

  Widget _buildHeader(BuildContext context, WidgetRef ref, int currentWeek, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month}/${now.day}';

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
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '第$currentWeek周',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· $weekStatus',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(context, Icons.calendar_month_outlined, () {
                _showWeekPicker(context, ref, currentWeek);
              }),
              _buildIconButton(context, Icons.download_outlined, () {}),
              _buildIconButton(context, Icons.share_outlined, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: colorScheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        hoverColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
        highlightColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
      ),
    );
  }

  void _showWeekPicker(BuildContext context, WidgetRef ref, int currentWeek) {
    final totalWeeks = ref.read(settingsProvider).totalWeeks;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _WeekPickerSheet(
          currentWeek: currentWeek,
          totalWeeks: totalWeeks,
          onWeekSelected: (week) {
            ref.read(currentWeekProvider.notifier).state = week;
            Navigator.pop(context);
          },
          onGoToCurrentWeek: () {
            final semesterStartDate = ref.read(settingsProvider).semesterStartDate;
            if (semesterStartDate != null) {
              ref.read(currentWeekProvider.notifier).state = _calculateCurrentWeek(semesterStartDate);
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  int _calculateCurrentWeek(DateTime semesterStart) {
    final now = DateTime.now();
    final difference = now.difference(semesterStart).inDays;
    return (difference ~/ 7) + 1;
  }
}

class _WeekPickerSheet extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final ValueChanged<int> onWeekSelected;
  final VoidCallback onGoToCurrentWeek;

  const _WeekPickerSheet({
    required this.currentWeek,
    required this.totalWeeks,
    required this.onWeekSelected,
    required this.onGoToCurrentWeek,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actualCurrentWeek = _calculateActualCurrentWeek();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择周数',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: totalWeeks,
            itemBuilder: (context, index) {
              final week = index + 1;
              return _buildWeekItem(context, week, actualCurrentWeek, colorScheme);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onGoToCurrentWeek,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('回到本周'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildWeekItem(BuildContext context, int week, int actualCurrentWeek, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final isSelected = week == currentWeek;
    final isCurrentWeek = week == actualCurrentWeek;
    final isPast = week < actualCurrentWeek;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      borderColor = colorScheme.primary;
    } else if (isPast) {
      backgroundColor = colorScheme.surfaceContainerLow;
      textColor = colorScheme.onSurfaceVariant;
      borderColor = colorScheme.outlineVariant;
    } else if (isCurrentWeek) {
      backgroundColor = colorScheme.secondaryContainer;
      textColor = colorScheme.onSecondaryContainer;
      borderColor = colorScheme.secondary;
    } else {
      backgroundColor = colorScheme.surface;
      textColor = colorScheme.onSurface;
      borderColor = colorScheme.outlineVariant;
    }

    return GestureDetector(
      onTap: () => onWeekSelected(week),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: isCurrentWeek ? 2 : 1),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '第$week周',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: isSelected || isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isCurrentWeek)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _calculateActualCurrentWeek() {
    final now = DateTime.now();
    final semesterStart = DateTime(2026, 2, 16);
    final difference = now.difference(semesterStart).inDays;
    return (difference ~/ 7) + 1;
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
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        MockSettingsRepository(
          settings: AppSettings(
            semesterStartDate: DateTime(2026, 2, 16),
            totalWeeks: 20,
          ),
        ),
      ),
      courseRepositoryProvider.overrideWithValue(
        MockCourseRepository(
          courses: [
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
          ],
        ),
      ),
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
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        MockSettingsRepository(
          settings: AppSettings(
            semesterStartDate: DateTime(2026, 2, 16),
            totalWeeks: 20,
          ),
        ),
      ),
      courseRepositoryProvider.overrideWithValue(
        MockCourseRepository(
          courses: [
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
          ],
        ),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    ),
  );
}
