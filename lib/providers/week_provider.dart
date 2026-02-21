import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/week_calculator.dart';
import 'settings_provider.dart';

final currentWeekProvider = StateProvider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  final semesterStart = settings.semesterStartDate ?? DateTime.now();
  return WeekCalculator.calculateCurrentWeek(semesterStart);
});

final weekDateRangeProvider = Provider.family<DateTimeRange, int>((ref, week) {
  final settings = ref.watch(settingsProvider);
  final semesterStart = settings.semesterStartDate ?? DateTime.now();
  return WeekCalculator.getWeekDateRange(semesterStart, week);
});

final currentWeekDateRangeProvider = Provider<DateTimeRange>((ref) {
  final currentWeek = ref.watch(currentWeekProvider);
  final semesterStart = ref.watch(settingsProvider).semesterStartDate ?? DateTime.now();
  return WeekCalculator.getWeekDateRange(semesterStart, currentWeek);
});

final isTodayProvider = Provider.family<bool, ({int week, int dayOfWeek})>((ref, params) {
  final settings = ref.watch(settingsProvider);
  final semesterStart = settings.semesterStartDate ?? DateTime.now();
  return WeekCalculator.isToday(semesterStart, params.week, params.dayOfWeek);
});

class WeekNotifier extends StateNotifier<int> {
  final Ref _ref;

  WeekNotifier(this._ref, int initialWeek) : super(initialWeek);

  void setWeek(int week) {
    final totalWeeks = _ref.read(settingsProvider).totalWeeks;
    if (week >= 1 && week <= totalWeeks) {
      state = week;
    }
  }

  void nextWeek() {
    final totalWeeks = _ref.read(settingsProvider).totalWeeks;
    if (state < totalWeeks) {
      state = state + 1;
    }
  }

  void previousWeek() {
    if (state > 1) {
      state = state - 1;
    }
  }

  void goToToday() {
    final settings = _ref.read(settingsProvider);
    final semesterStart = settings.semesterStartDate ?? DateTime.now();
    final currentWeek = WeekCalculator.calculateCurrentWeek(semesterStart);
    state = currentWeek;
  }

  void goToWeek(int week) {
    final totalWeeks = _ref.read(settingsProvider).totalWeeks;
    if (week >= 1 && week <= totalWeeks) {
      state = week;
    }
  }
}

final weekNotifierProvider = StateNotifierProvider<WeekNotifier, int>((ref) {
  final currentWeek = ref.watch(currentWeekProvider);
  return WeekNotifier(ref, currentWeek);
});
