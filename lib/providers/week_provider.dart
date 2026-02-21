import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/week_calculator.dart';
import 'settings_provider.dart';

final currentWeekProvider = StateNotifierProvider<WeekNotifier, int>((ref) {
  final settings = ref.watch(settingsProvider);
  final semesterStart = settings.valueOrNull?.semesterStartDate;
  
  if (semesterStart != null) {
    return WeekNotifier(WeekCalculator.calculateCurrentWeek(semesterStart));
  }
  return WeekNotifier(1);
});

class WeekNotifier extends StateNotifier<int> {
  WeekNotifier(int initialWeek) : super(initialWeek);

  void setWeek(int week) {
    if (week >= 1 && week <= 25) {
      state = week;
    }
  }

  void nextWeek(int maxWeeks) {
    if (state < maxWeeks) {
      state++;
    }
  }

  void previousWeek() {
    if (state > 1) {
      state--;
    }
  }

  void goToFirstWeek() {
    state = 1;
  }

  void goToLastWeek(int maxWeeks) {
    state = maxWeeks;
  }
}
