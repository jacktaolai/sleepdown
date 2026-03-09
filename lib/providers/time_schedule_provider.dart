import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentWeekNotifier extends StateNotifier<int> {
  final DateTime _semesterStartDate;
  final int _totalWeeks;

  CurrentWeekNotifier(this._semesterStartDate, this._totalWeeks) 
      : super(_calculateCurrentWeek(_semesterStartDate, _totalWeeks));

  static int _calculateCurrentWeek(DateTime semesterStart, int totalWeeks) {
    final now = DateTime.now();
    final diff = now.difference(semesterStart).inDays;
    if (diff < 0) return 1;
    final week = (diff / 7).floor() + 1;
    return week > totalWeeks ? totalWeeks : week;
  }

  void setWeek(int week) {
    if (week >= 1 && week <= _totalWeeks) {
      state = week;
    }
  }

  void previousWeek() {
    if (state > 1) {
      state--;
    }
  }

  void nextWeek() {
    if (state < _totalWeeks) {
      state++;
    }
  }

  void resetToCurrentWeek() {
    state = _calculateCurrentWeek(_semesterStartDate, _totalWeeks);
  }
}
