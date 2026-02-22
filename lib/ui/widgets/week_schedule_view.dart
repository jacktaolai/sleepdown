import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/course.dart';
import 'course_card.dart';

/// 课程表周视图组件
/// 包含日期切换栏和课程网格，确保对齐
/// 顶部日期与底部课程使用统一网格结构
class WeekScheduleView extends ConsumerWidget {
  final List<Course> courses;
  final int currentWeek;

  const WeekScheduleView({
    super.key,
    required this.courses,
    required this.currentWeek,
  });

  static const double timeColumnWidth = 48.0;
  static const double sectionHeight = 64.0;
  static const int totalSections = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnWidth = (constraints.maxWidth - timeColumnWidth) / 7;

          return Column(
            children: [
              _DateHeaderRow(
                currentWeek: currentWeek,
                columnWidth: columnWidth,
                timeColumnWidth: timeColumnWidth,
              ),
              Expanded(
                child: _ScheduleGridInner(
                  courses: courses,
                  currentWeek: currentWeek,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 顶部日期行 - 使用与课程网格完全统一的布局
class _DateHeaderRow extends StatelessWidget {
  final int currentWeek;
  final double columnWidth;
  final double timeColumnWidth;

  const _DateHeaderRow({
    required this.currentWeek,
    required this.columnWidth,
    required this.timeColumnWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final now = DateTime.now();
    final semesterStart = DateTime(now.year, 2, 16);
    final weekStart = semesterStart.add(Duration(days: (currentWeek - 1) * 7 - (semesterStart.weekday - 1)));
    final days = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    final today = DateTime.now();
    final todayIndex = today.difference(weekStart).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: timeColumnWidth,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${days[0].month}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '月',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(7, (index) {
            final date = days[index];
            final isToday = index == todayIndex && currentWeek == _getWeekNumber(today, semesterStart);

            return Container(
              width: columnWidth,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday ? colorScheme.primary : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${date.day}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isToday ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return days[weekday - 1];
  }

  int _getWeekNumber(DateTime date, DateTime semesterStart) {
    return ((date.difference(semesterStart).inDays + semesterStart.weekday - 1) / 7).floor() + 1;
  }
}

/// 内部使用的课程网格
class _ScheduleGridInner extends StatelessWidget {
  final List<Course> courses;
  final int currentWeek;

  const _ScheduleGridInner({
    required this.courses,
    required this.currentWeek,
  });

  static const double sectionHeight = 64.0;
  static const double timeColumnWidth = 48.0;
  static const int totalSections = 12;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - timeColumnWidth) / 7;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: timeColumnWidth,
                child: Column(
                  children: List.generate(totalSections, (index) {
                    final section = index + 1;
                    return Container(
                      height: sectionHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          right: BorderSide(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$section',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _getTimeForSection(section),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 8,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: totalSections * sectionHeight,
                  child: Stack(
                    children: [
                      Column(
                        children: List.generate(totalSections, (index) {
                          return Container(
                            height: sectionHeight,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      Row(
                        children: List.generate(7, (index) {
                          return Container(
                            width: columnWidth,
                            height: totalSections * sectionHeight,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      ...courses.map((course) {
                        final isActive = course.isActiveInWeek(currentWeek);

                        return Positioned(
                          top: (course.startSection - 1) * sectionHeight,
                          left: (course.dayOfWeek - 1) * columnWidth,
                          width: columnWidth,
                          height: (course.endSection - course.startSection + 1) * sectionHeight,
                          child: CourseCard(
                            course: course,
                            isCurrentWeek: isActive,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/course/${course.id}',
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTimeForSection(int section) {
    final startHour = 8 + (section - 1);
    final startMinute = 0;
    final endHour = startHour;
    final endMinute = 45;

    return '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}\n${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }
}

// ============== Widget Preview Annotations ==============

/// 预览: WeekScheduleView - 空课程表
@Preview(
  name: 'WeekScheduleView - 空课程表',
  group: 'WeekScheduleView',
  size: Size(360, 600),
)
Widget weekScheduleViewEmptyPreview() {
  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 600,
        child: const WeekScheduleView(
          courses: [],
          currentWeek: 1,
        ),
      ),
    ),
  );
}

/// 预览: WeekScheduleView - 有课程
@Preview(
  name: 'WeekScheduleView - 有课程',
  group: 'WeekScheduleView',
  size: Size(360, 600),
)
Widget weekScheduleViewWithCoursesPreview() {
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

  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 600,
        child: WeekScheduleView(
          courses: courses,
          currentWeek: 1,
        ),
      ),
    ),
  );
}

/// 预览: WeekScheduleView - 暗色模式
@Preview(
  name: 'WeekScheduleView - 暗色模式',
  group: 'WeekScheduleView',
  size: Size(360, 600),
  brightness: Brightness.dark,
)
Widget weekScheduleViewDarkPreview() {
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

  return MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 600,
        child: WeekScheduleView(
          courses: courses,
          currentWeek: 1,
        ),
      ),
    ),
  );
}

/// 预览: WeekScheduleView - 课程跨节
@Preview(
  name: 'WeekScheduleView - 跨节课程',
  group: 'WeekScheduleView',
  size: Size(360, 600),
)
Widget weekScheduleViewMultiSectionPreview() {
  final courses = [
    Course(
      id: '1',
      name: '数据结构',
      teacher: '张三',
      location: 'A301',
      dayOfWeek: 1,
      startSection: 1,
      endSection: 4,
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
      dayOfWeek: 3,
      startSection: 5,
      endSection: 6,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 600,
        child: WeekScheduleView(
          courses: courses,
          currentWeek: 1,
        ),
      ),
    ),
  );
}
