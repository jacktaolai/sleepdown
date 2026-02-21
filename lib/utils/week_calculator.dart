import 'package:flutter/material.dart';

class WeekCalculator {
  static int calculateCurrentWeek(DateTime semesterStart) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(semesterStart.year, semesterStart.month, semesterStart.day);
    
    final diff = today.difference(start).inDays;
    if (diff < 0) return 1;
    return (diff / 7).floor() + 1;
  }

  static DateTimeRange getWeekDateRange(DateTime semesterStart, int week) {
    final start = semesterStart.add(Duration(days: (week - 1) * 7));
    final end = start.add(const Duration(days: 6));
    return DateTimeRange(start: start, end: end);
  }

  static DateTime getDateForDayOfWeek(DateTime semesterStart, int week, int dayOfWeek) {
    final weekStart = semesterStart.add(Duration(days: (week - 1) * 7));
    return weekStart.add(Duration(days: dayOfWeek - 1));
  }

  static int getDayOfWeek(DateTime date) {
    final weekday = date.weekday;
    return weekday;
  }

  static bool isToday(DateTime semesterStart, int week, int dayOfWeek) {
    final targetDate = getDateForDayOfWeek(semesterStart, week, dayOfWeek);
    final now = DateTime.now();
    return targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day;
  }

  static int getWeeksBetween(DateTime start, DateTime end) {
    final diff = end.difference(start).inDays;
    return (diff / 7).ceil();
  }
}
