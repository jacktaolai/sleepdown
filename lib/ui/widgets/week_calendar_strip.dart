import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class WeekCalendarStrip extends ConsumerWidget {
  const WeekCalendarStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.watch(currentWeekProvider);
    final dateRange = ref.watch(weekDateRangeProvider(currentWeek));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate dates for the week
    final days = List.generate(7, (index) {
      return dateRange.start.add(Duration(days: index));
    });

    final month = dateRange.start.month;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Month Indicator
          Container(
            width: 48,
            padding: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Color(0x33C3C7CF), // outlineVariant with opacity
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$month',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '月',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Days Row
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((date) {
                final isToday = ref.watch(isTodayProvider((week: currentWeek, dayOfWeek: date.weekday)));
                // debugPrint('Date: $date, isToday: $isToday');
                final dayName = _getDayName(date.weekday);
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
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
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return days[weekday - 1];
  }
}
