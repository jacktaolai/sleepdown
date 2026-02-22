import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/app_settings.dart';
import '../../models/time_schedule.dart';
import '../../repository/settings_repository.dart';
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

// ============== Mock Repository for Preview ==============

/// 用于预览的 Mock SettingsRepository
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

// ============== Widget Preview Annotations ==============

/// 预览: WeekCalendarStrip - 当前周
@Preview(
  name: 'WeekCalendarStrip - 第1周',
  group: 'WeekCalendarStrip',
  size: Size(360, 80),
)
Widget weekCalendarStripPreview() {
  // 设置学期开始日期为2026年2月16日（周一），第1周
  final settings = AppSettings(
    semesterStartDate: DateTime(2026, 2, 16),
    totalWeeks: 20,
  );

  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(MockSettingsRepository(settings: settings)),
    ],
    child: MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: const Scaffold(
        body: WeekCalendarStrip(),
      ),
    ),
  );
}

/// 预览: WeekCalendarStrip - 第8周（今天）
@Preview(
  name: 'WeekCalendarStrip - 第8周(今天)',
  group: 'WeekCalendarStrip',
  size: Size(360, 80),
)
Widget weekCalendarStripWeek8Preview() {
  // 设置学期开始日期为2026年2月16日，第8周周三为今天(2026-04-10)
  final settings = AppSettings(
    semesterStartDate: DateTime(2026, 2, 16),
    totalWeeks: 20,
  );

  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(MockSettingsRepository(settings: settings)),
    ],
    child: MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: const Scaffold(
        body: WeekCalendarStrip(),
      ),
    ),
  );
}

/// 预览: WeekCalendarStrip - 暗色模式
@Preview(
  name: 'WeekCalendarStrip - 暗色模式',
  group: 'WeekCalendarStrip',
  size: Size(360, 80),
  brightness: Brightness.dark,
)
Widget weekCalendarStripDarkPreview() {
  final settings = AppSettings(
    semesterStartDate: DateTime(2026, 2, 16),
    totalWeeks: 20,
  );

  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(MockSettingsRepository(settings: settings)),
    ],
    child: MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: WeekCalendarStrip(),
      ),
    ),
  );
}
