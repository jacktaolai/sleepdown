import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleepdown/models/app_settings.dart';

void main() {
  group('WeekNotifier logic tests', () {
    test('should validate week range correctly', () {
      const totalWeeks = 18;
      
      expect(WeekNotifierHelper.setWeek(1, totalWeeks), equals(1));
      expect(WeekNotifierHelper.setWeek(10, totalWeeks), equals(10));
      expect(WeekNotifierHelper.setWeek(18, totalWeeks), equals(18));
      
      expect(WeekNotifierHelper.setWeek(0, totalWeeks), equals(1));
      expect(WeekNotifierHelper.setWeek(-1, totalWeeks), equals(1));
      expect(WeekNotifierHelper.setWeek(19, totalWeeks), equals(1));
      expect(WeekNotifierHelper.setWeek(100, totalWeeks), equals(1));
    });

    test('should calculate next week correctly', () {
      const totalWeeks = 18;
      
      expect(WeekNotifierHelper.nextWeek(1, totalWeeks), equals(2));
      expect(WeekNotifierHelper.nextWeek(5, totalWeeks), equals(6));
      expect(WeekNotifierHelper.nextWeek(17, totalWeeks), equals(18));
      expect(WeekNotifierHelper.nextWeek(18, totalWeeks), equals(18));
    });

    test('should calculate previous week correctly', () {
      const totalWeeks = 18;
      
      expect(WeekNotifierHelper.previousWeek(1, totalWeeks), equals(1));
      expect(WeekNotifierHelper.previousWeek(2, totalWeeks), equals(1));
      expect(WeekNotifierHelper.previousWeek(5, totalWeeks), equals(4));
      expect(WeekNotifierHelper.previousWeek(18, totalWeeks), equals(17));
    });

    test('should handle week boundaries correctly', () {
      const totalWeeks = 18;
      
      for (var week = 1; week <= totalWeeks; week++) {
        final next = WeekNotifierHelper.nextWeek(week, totalWeeks);
        expect(next, lessThanOrEqualTo(totalWeeks));
        expect(next, greaterThanOrEqualTo(week));
      }
      
      for (var week = 1; week <= totalWeeks; week++) {
        final prev = WeekNotifierHelper.previousWeek(week, totalWeeks);
        expect(prev, greaterThanOrEqualTo(1));
        expect(prev, lessThanOrEqualTo(week));
      }
    });
  });

  group('currentWeekProvider logic', () {
    test('should calculate week from semester start', () {
      final semesterStart = DateTime(2026, 2, 17);
      final settings = AppSettings(
        semesterStartDate: semesterStart,
        totalWeeks: 18,
      );

      final week = calculateCurrentWeek(settings);
      expect(week, greaterThanOrEqualTo(1));
      expect(week, lessThanOrEqualTo(18));
    });

    test('should handle null semester start date', () {
      const settings = AppSettings();
      
      final week = calculateCurrentWeek(settings);
      expect(week, greaterThanOrEqualTo(1));
    });
  });

  group('weekDateRangeProvider logic', () {
    test('should calculate week date range correctly', () {
      final semesterStart = DateTime(2026, 2, 17);
      
      final week1 = calculateWeekDateRange(semesterStart, 1);
      expect(week1.start, equals(DateTime(2026, 2, 17)));
      expect(week1.end, equals(DateTime(2026, 2, 23)));
      
      final week2 = calculateWeekDateRange(semesterStart, 2);
      expect(week2.start, equals(DateTime(2026, 2, 24)));
      expect(week2.end, equals(DateTime(2026, 3, 2)));
    });

    test('should calculate different weeks correctly', () {
      final semesterStart = DateTime(2026, 2, 17);
      
      final week10 = calculateWeekDateRange(semesterStart, 10);
      expect(week10.start.day, equals(21));
      expect(week10.end.day, equals(27));
    });
  });
}

class WeekNotifierHelper {
  static int setWeek(int week, int totalWeeks) {
    if (week >= 1 && week <= totalWeeks) {
      return week;
    }
    return 1;
  }

  static int nextWeek(int currentWeek, int totalWeeks) {
    if (currentWeek < totalWeeks) {
      return currentWeek + 1;
    }
    return totalWeeks;
  }

  static int previousWeek(int currentWeek, int totalWeeks) {
    if (currentWeek > 1) {
      return currentWeek - 1;
    }
    return 1;
  }
}

int calculateCurrentWeek(AppSettings settings) {
  final semesterStart = settings.semesterStartDate ?? DateTime.now();
  final now = DateTime.now();
  final diff = now.difference(semesterStart).inDays;
  if (diff < 0) return 1;
  return (diff / 7).floor() + 1;
}

DateTimeRange calculateWeekDateRange(DateTime semesterStart, int week) {
  final start = semesterStart.add(Duration(days: (week - 1) * 7));
  final end = start.add(const Duration(days: 6));
  return DateTimeRange(start: start, end: end);
}
