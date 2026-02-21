import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/utils/week_calculator.dart';

void main() {
  group('WeekCalculator', () {
    test('should calculate current week correctly', () {
      final semesterStart = DateTime(2026, 2, 17);
      
      expect(
        WeekCalculator.calculateCurrentWeek(semesterStart),
        greaterThanOrEqualTo(1),
      );
    });

    test('should return 1 for future semester start', () {
      final futureStart = DateTime(2030, 1, 1);
      
      expect(WeekCalculator.calculateCurrentWeek(futureStart), equals(1));
    });

    test('should get week date range correctly', () {
      final semesterStart = DateTime(2026, 2, 16);
      final range = WeekCalculator.getWeekDateRange(semesterStart, 1);

      expect(range.start, equals(DateTime(2026, 2, 16)));
      expect(range.end, equals(DateTime(2026, 2, 22)));
    });

    test('should get date for day of week correctly', () {
      final semesterStart = DateTime(2026, 2, 16);
      
      final monday = WeekCalculator.getDateForDayOfWeek(semesterStart, 1, 1);
      expect(monday, equals(DateTime(2026, 2, 16)));

      final sunday = WeekCalculator.getDateForDayOfWeek(semesterStart, 1, 7);
      expect(sunday, equals(DateTime(2026, 2, 22)));

      final week2Monday = WeekCalculator.getDateForDayOfWeek(semesterStart, 2, 1);
      expect(week2Monday, equals(DateTime(2026, 2, 23)));
    });

    test('should get day of week correctly', () {
      final tuesday = DateTime(2026, 2, 17);
      expect(WeekCalculator.getDayOfWeek(tuesday), equals(2));

      final wednesday = DateTime(2026, 2, 18);
      expect(WeekCalculator.getDayOfWeek(wednesday), equals(3));

      final sunday = DateTime(2026, 2, 22);
      expect(WeekCalculator.getDayOfWeek(sunday), equals(7));
      
      final monday = DateTime(2026, 2, 16);
      expect(WeekCalculator.getDayOfWeek(monday), equals(1));
    });

    test('should check if today correctly', () {
      final now = DateTime.now();
      final semesterStart = now.subtract(Duration(days: now.weekday - 1));
      
      expect(
        WeekCalculator.isToday(semesterStart, 1, now.weekday),
        isTrue,
      );
    });

    test('should calculate weeks between dates', () {
      final start = DateTime(2026, 2, 17);
      final end = DateTime(2026, 5, 17);

      final weeks = WeekCalculator.getWeeksBetween(start, end);
      expect(weeks, greaterThan(0));
    });
  });
}
