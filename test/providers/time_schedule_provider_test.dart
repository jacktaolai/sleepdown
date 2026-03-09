import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/time_schedule_provider.dart';

void main() {
  group('CurrentWeekNotifier', () {
    test('initial state should be current week', () {
      final semesterStart = DateTime(2026, 2, 23);
      final notifier = CurrentWeekNotifier(semesterStart, 18);
      
      expect(notifier.state, greaterThanOrEqualTo(1));
      expect(notifier.state, lessThanOrEqualTo(18));
    });

    test('setWeek should update to specified week', () {
      final notifier = CurrentWeekNotifier(DateTime(2026, 2, 23), 18);
      
      notifier.setWeek(5);
      
      expect(notifier.state, 5);
    });

    test('setWeek should not update if week is out of range', () {
      final notifier = CurrentWeekNotifier(DateTime(2026, 2, 23), 18);
      final initialWeek = notifier.state;
      
      notifier.setWeek(0);
      expect(notifier.state, initialWeek);
      
      notifier.setWeek(19);
      expect(notifier.state, initialWeek);
    });

    test('previousWeek should decrease week by 1', () {
      final notifier = CurrentWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setWeek(5);
      
      notifier.previousWeek();
      
      expect(notifier.state, 4);
    });

    test('previousWeek should not go below 1', () {
      final notifier = CurrentWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setWeek(1);
      
      notifier.previousWeek();
      
      expect(notifier.state, 1);
    });

    test('nextWeek should increase week by 1', () {
      final notifier = CurrentWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setWeek(5);
      
      notifier.nextWeek();
      
      expect(notifier.state, 6);
    });

    test('nextWeek should not exceed total weeks', () {
      final notifier = CurrentWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setWeek(18);
      
      notifier.nextWeek();
      
      expect(notifier.state, 18);
    });

    test('resetToCurrentWeek should recalculate current week', () {
      final notifier = CurrentWeekNotifier(DateTime(2026, 2, 23), 18);
      notifier.setWeek(10);
      
      notifier.resetToCurrentWeek();
      
      expect(notifier.state, greaterThanOrEqualTo(1));
    });
  });
}
