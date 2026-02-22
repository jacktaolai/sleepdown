import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/schedule_grid.dart';
import '../widgets/week_calendar_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.watch(currentWeekProvider);
    final courses = ref.watch(courseListProvider);
    
    // Filter courses to show only those relevant for the current week or generally active
    // For now, we pass all courses and let ScheduleGrid/CourseCard handle the "not current week" styling
    // But we might want to filter out courses that are completely irrelevant (e.g. different semester)
    // Assuming all courses in provider are for current semester.

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref, currentWeek),
            const WeekCalendarStrip(),
            Expanded(
              child: ScheduleGrid(
                courses: courses,
                currentWeek: currentWeek,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add course
          Navigator.of(context).pushNamed('/course/edit');
        },
        child: const Icon(Icons.add),
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
