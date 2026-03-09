import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'course_table_provider.dart';

class DisplayedWeekNotifier extends StateNotifier<int> {
  final DateTime _semesterStartDate;
  final int _totalWeeks;

  DisplayedWeekNotifier(this._semesterStartDate, this._totalWeeks) 
      : super(_calculateActualCurrentWeek(_semesterStartDate, _totalWeeks));

  static int _calculateActualCurrentWeek(DateTime semesterStart, int totalWeeks) {
    final now = DateTime.now();
    final diff = now.difference(semesterStart).inDays;
    if (diff < 0) return 1;
    final week = (diff / 7).floor() + 1;
    return week > totalWeeks ? totalWeeks : week;
  }

  void setDisplayedWeek(int week) {
    if (week >= 1 && week <= _totalWeeks) {
      state = week;
    }
  }

  void switchToPreviousWeek() {
    if (state > 1) {
      state--;
    }
  }

  void switchToNextWeek() {
    if (state < _totalWeeks) {
      state++;
    }
  }

  void resetToActualCurrentWeek() {
    state = _calculateActualCurrentWeek(_semesterStartDate, _totalWeeks);
  }
}

final currentWeekProvider = StateNotifierProvider<DisplayedWeekNotifier, int>((ref) {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return DisplayedWeekNotifier(DateTime.now(), 18);
  
  return DisplayedWeekNotifier(
    tableState.table!.semesterStartDate,
    tableState.table!.totalWeeks,
  );
});
