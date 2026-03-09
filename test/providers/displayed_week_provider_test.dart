import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/displayed_week_provider.dart';

void main() {
  group('DisplayedWeekNotifier', () {
    test('initial state should be actual current week', () {
      final semesterStart = DateTime(2026, 2, 23);
      final notifier = DisplayedWeekNotifier(semesterStart, 18);
      
      expect(notifier.state, greaterThanOrEqualTo(1));
      expect(notifier.state, lessThanOrEqualTo(18));
    });

    test('setDisplayedWeek should update to specified week', () {
      final notifier = DisplayedWeekNotifier(DateTime(2026, 2, 23), 18);
      
      notifier.setDisplayedWeek(5);
      
      expect(notifier.state, 5);
    });

    test('setDisplayedWeek should not update if week is out of range', () {
      final notifier = DisplayedWeekNotifier(DateTime(2026, 2, 23), 18);
      final initialWeek = notifier.state;
      
      notifier.setDisplayedWeek(0);
      expect(notifier.state, initialWeek);
      
      notifier.setDisplayedWeek(19);
      expect(notifier.state, initialWeek);
    });

    test('switchToPreviousWeek should decrease week by 1', () {
      final notifier = DisplayedWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setDisplayedWeek(5);
      
      notifier.switchToPreviousWeek();
      
      expect(notifier.state, 4);
    });

    test('switchToPreviousWeek should not go below 1', () {
      final notifier = DisplayedWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setDisplayedWeek(1);
      
      notifier.switchToPreviousWeek();
      
      expect(notifier.state, 1);
    });

    test('switchToNextWeek should increase week by 1', () {
      final notifier = DisplayedWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setDisplayedWeek(5);
      
      notifier.switchToNextWeek();
      
      expect(notifier.state, 6);
    });

    test('switchToNextWeek should not exceed total weeks', () {
      final notifier = DisplayedWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setDisplayedWeek(18);
      
      notifier.switchToNextWeek();
      
      expect(notifier.state, 18);
    });

    test('resetToActualCurrentWeek should recalculate current week', () {
      final notifier = DisplayedWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setDisplayedWeek(10);
      
      notifier.resetToActualCurrentWeek();
      
      expect(notifier.state, greaterThanOrEqualTo(1));
    });
  });
}
