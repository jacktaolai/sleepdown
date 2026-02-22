import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/course.dart';
import '../../theme/app_theme.dart';
import 'course_card.dart';

class ScheduleGrid extends ConsumerWidget {
  final List<Course> courses;
  final int currentWeek;

  const ScheduleGrid({
    super.key,
    required this.courses,
    required this.currentWeek,
  });

  static const double sectionHeight = 64.0;
  static const double timeColumnWidth = 48.0;
  static const int totalSections = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate column width based on available width minus time column
        final availableWidth = constraints.maxWidth - timeColumnWidth;
        final columnWidth = availableWidth / 7;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Column
              SizedBox(
                width: timeColumnWidth,
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
                            width: columnWidth,
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
                        // Only show if active or if we want to show inactive courses (design implies yes)
                        // But we need to handle overlapping.
                        // For MVP, let's just show them.
                        
                        return Positioned(
                          top: (course.startSection - 1) * sectionHeight,
                          left: (course.dayOfWeek - 1) * columnWidth,
                          width: columnWidth,
                          height: (course.endSection - course.startSection + 1) * sectionHeight,
                          child: CourseCard(
                            course: course,
                            isCurrentWeek: isActive,
                            onTap: () {
                              // Navigate to detail
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
