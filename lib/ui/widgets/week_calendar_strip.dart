import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/app_settings.dart';
import '../../models/time_schedule.dart';
import '../../repository/settings_repository.dart';
import '../../providers/providers.dart';

class WeekCalendarStrip extends ConsumerWidget {
  final double columnWidth;
  final double timeColumnWidth;

  const WeekCalendarStrip({
    super.key,
    this.columnWidth = 0,
    this.timeColumnWidth = 48.0,
  });

  static const double defaultTimeColumnWidth = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.watch(currentWeekProvider);
    final dateRange = ref.watch(weekDateRangeProvider(currentWeek));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 使用传入的列宽或计算默认值
    final effectiveTimeColumnWidth = timeColumnWidth != 0 ? timeColumnWidth : defaultTimeColumnWidth;
    final effectiveColumnWidth = columnWidth != 0
        ? columnWidth
        : (MediaQuery.of(context).size.width - 32 - effectiveTimeColumnWidth) / 7;

    // Calculate dates for the week
    final days = List.generate(7, (index) {
      return dateRange.start.add(Duration(days: index));
    });

    final month = dateRange.start.month;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(4),
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
        children: [
          // Month Indicator - 与底部时间列对齐
          SizedBox(
            width: effectiveTimeColumnWidth,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$month',
                    style: theme.textTheme.labelMedium?.copyWith(
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
          // Days Row - 每列宽度与底部课程网格一致
          ...List.generate(7, (index) {
            final date = days[index];
            final isToday = ref.watch(isTodayProvider((week: currentWeek, dayOfWeek: date.weekday)));
            final dayName = _getDayName(date.weekday);

            return Container(
              width: effectiveColumnWidth,
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
                    dayName,
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
