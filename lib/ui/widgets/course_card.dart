import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/course.dart';
import '../../theme/app_theme.dart';

class CourseCard extends Card {
  final Course course;
  final bool isCurrentWeek;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.isCurrentWeek = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final cardColors = AppTheme.getCourseCardColorScheme(course.colorValue, brightness);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentWeek ? cardColors.container : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentWeek)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '[非本周]',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            Text(
              course.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isCurrentWeek ? cardColors.onContainer : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (course.location.isNotEmpty)
              _buildInfoRow(
                context,
                Icons.location_on_outlined,
                '@${course.location}',
                isCurrentWeek ? cardColors.onContainer : colorScheme.onSurfaceVariant,
              ),
            if (course.teacher.isNotEmpty)
              _buildInfoRow(
                context,
                Icons.person_outline,
                course.teacher,
                isCurrentWeek ? cardColors.onContainer : colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Widget Preview Annotations ==============

/// 预览: CourseCard - 当前周课程卡片 (亮色)
@Preview(
  name: 'CourseCard - 当前周',
  group: 'CourseCard',
  size: Size(50, 120),
)
Widget courseCardPreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: SizedBox(
        width: 50,
        height: 120,
        child: CourseCard(
          course: Course(
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
          isCurrentWeek: true,
        ),
      ),
    ),
  );
}

/// 预览: CourseCard - 当前周课程卡片 (暗色)
@Preview(
  name: 'CourseCard - 当前周(暗色)',
  group: 'CourseCard',
  size: Size(50, 120),
  brightness: Brightness.dark,
)
Widget courseCardDarkPreview() {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: SizedBox(
        width: 50,
        height: 120,
        child: CourseCard(
          course: Course(
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
          isCurrentWeek: true,
        ),
      ),
    ),
  );
}

/// 预览: CourseCard - 非当前周课程卡片
@Preview(
  name: 'CourseCard - 非本周',
  group: 'CourseCard',
  size: Size(50, 120),
)
Widget courseCardNotCurrentWeekPreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: SizedBox(
        width: 50,
        height: 120,
        child: CourseCard(
          course: Course(
            id: '2',
            name: '算法设计',
            teacher: '李四',
            location: 'B205',
            dayOfWeek: 3,
            startSection: 3,
            endSection: 4,
            weekRanges: [WeekRange(start: 1, end: 16)],
            colorValue: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          isCurrentWeek: false,
        ),
      ),
    ),
  );
}

/// 预览: CourseCard - 多颜色变体 (亮色)
@Preview(
  name: 'CourseCard - 颜色变体',
  group: 'CourseCard',
  size: Size(250, 120),
)
Widget courseCardMultiColorPreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Row(
        children: List.generate(5, (index) {
          return SizedBox(
            width: 50,
            height: 120,
            child: CourseCard(
              course: Course(
                id: '$index',
                name: '课程$index',
                teacher: '教师$index',
                location: '教室$index',
                dayOfWeek: 1,
                startSection: 1,
                endSection: 2,
                weekRanges: [WeekRange(start: 1, end: 16)],
                colorValue: index,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              isCurrentWeek: true,
            ),
          );
        }),
      ),
    ),
  );
}

/// 预览: CourseCard - 多颜色变体 (暗色)
@Preview(
  name: 'CourseCard - 颜色变体(暗色)',
  group: 'CourseCard',
  size: Size(500, 100),
  brightness: Brightness.dark,
)
Widget courseCardMultiColorDarkPreview() {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: Row(
        children: List.generate(5, (index) {
          return SizedBox(
            width: 100,
            height: 80,
            child: CourseCard(
              course: Course(
                id: '$index',
                name: '课程$index',
                teacher: '教师$index',
                location: '教室$index',
                dayOfWeek: 1,
                startSection: 1,
                endSection: 2,
                weekRanges: [WeekRange(start: 1, end: 16)],
                colorValue: index,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              isCurrentWeek: true,
            ),
          );
        }),
      ),
    ),
  );
}
