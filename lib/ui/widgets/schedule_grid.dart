import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/course.dart';
import '../../theme/app_theme.dart';
import 'course_card.dart';

class ScheduleGrid extends ConsumerWidget {
  final List<Course> courses;
  final int currentWeek;
  final double columnWidth;
  final double timeColumnWidth;

  const ScheduleGrid({
    super.key,
    required this.courses,
    required this.currentWeek,
    this.columnWidth = 0, // 默认值会被忽略，需要外部传入
    this.timeColumnWidth = 48.0,
  });

  static const double sectionHeight = 64.0;
  static const double defaultTimeColumnWidth = 48.0;
  static const int totalSections = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用传入的 columnWidth，或计算默认值
    final effectiveTimeColumnWidth = timeColumnWidth != 0 ? timeColumnWidth : defaultTimeColumnWidth;
    final effectiveColumnWidth = columnWidth != 0
        ? columnWidth
        : (MediaQuery.of(context).size.width - 32 - effectiveTimeColumnWidth) / 7;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: effectiveTimeColumnWidth,
            child: Column(
              children: List.generate(totalSections, (index) {
                final section = index + 1;
                return Container(
                  height: sectionHeight,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0x1AC3C7CF), // outlineVariant with low opacity
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Color(0x1AC3C7CF),
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
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _getTimeForSection(section),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.onSurfaceVariant,
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
          // Course Grid Area
          Expanded(
            child: SizedBox(
              height: totalSections * sectionHeight,
              child: Stack(
                children: [
                  // Horizontal Grid Lines
                  Column(
                    children: List.generate(totalSections, (index) {
                      return Container(
                        height: sectionHeight,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0x1AC3C7CF),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Vertical Grid Lines
                  Row(
                    children: List.generate(7, (index) {
                      return Container(
                        width: effectiveColumnWidth,
                        height: totalSections * sectionHeight,
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Color(0x1AC3C7CF),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Courses
                  ...courses.map((course) {
                    final isActive = course.isActiveInWeek(currentWeek);

                    return Positioned(
                      top: (course.startSection - 1) * sectionHeight,
                      left: (course.dayOfWeek - 1) * effectiveColumnWidth,
                      width: effectiveColumnWidth,
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
  }

  String _getTimeForSection(int section) {
    // Mock times based on standard schedule
    // 1: 08:00 - 08:45
    // 2: 08:55 - 09:40
    // ...
    // This should ideally come from SettingsProvider
    final startHour = 8 + (section - 1);
    final startMinute = 0;
    final endHour = startHour;
    final endMinute = 45;

    return '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}\n${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }
}

// ============== Widget Preview Annotations ==============

/// 预览: ScheduleGrid - 空课程表
@Preview(
  name: 'ScheduleGrid - 空课程表',
  group: 'ScheduleGrid',
  size: Size(360, 800),
)
Widget scheduleGridEmptyPreview() {
  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 800,
        child: const ScheduleGrid(
          courses: [],
          currentWeek: 1,
        ),
      ),
    ),
  );
}

/// 预览: ScheduleGrid - 有课程
@Preview(
  name: 'ScheduleGrid - 有课程',
  group: 'ScheduleGrid',
  size: Size(360, 800),
)
Widget scheduleGridWithCoursesPreview() {
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
  ];

  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 800,
        child: ScheduleGrid(
          courses: courses,
          currentWeek: 1,
        ),
      ),
    ),
  );
}
