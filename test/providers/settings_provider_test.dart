import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/app_settings.dart';
import 'package:sleepdown/models/time_schedule.dart';

void main() {
  group('SettingsNotifier Logic Tests', () {
    test('should create with default settings', () {
      const settings = AppSettings();
      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.totalWeeks, equals(18));
    });

    test('should copy with new theme mode', () {
      const settings = AppSettings();
      final newSettings = settings.copyWith(themeMode: ThemeMode.dark);
      expect(newSettings.themeMode, equals(ThemeMode.dark));
      expect(newSettings.totalWeeks, equals(18));
    });

    test('should copy with new total weeks', () {
      const settings = AppSettings();
      final newSettings = settings.copyWith(totalWeeks: 20);
      expect(newSettings.totalWeeks, equals(20));
      expect(newSettings.themeMode, equals(ThemeMode.system));
    });

    test('should copy with new semester start date', () {
      const settings = AppSettings();
      final newDate = DateTime(2026, 3, 1);
      final newSettings = settings.copyWith(semesterStartDate: newDate);
      expect(newSettings.semesterStartDate, equals(newDate));
    });

    test('should clear semester start date', () {
      final settings = AppSettings(semesterStartDate: DateTime(2026, 3, 1));
      final newSettings = settings.copyWith(clearSemesterStartDate: true);
      expect(newSettings.semesterStartDate, isNull);
    });
  });

  group('TimeScheduleNotifier Logic Tests', () {
    test('should create time schedule', () {
      final schedule = TimeSchedule(
        id: 'test',
        name: 'Test Schedule',
        slots: const [],
      );
      expect(schedule.id, equals('test'));
      expect(schedule.name, equals('Test Schedule'));
      expect(schedule.isDefault, isFalse);
    });

    test('should copy time schedule with new name', () {
      final schedule = TimeSchedule(
        id: 'test',
        name: 'Original',
        slots: const [],
      );
      final updated = schedule.copyWith(name: 'Updated');
      expect(updated.name, equals('Updated'));
      expect(updated.id, equals('test'));
    });

    test('should set default flag', () {
      final schedule = TimeSchedule(
        id: 'test',
        name: 'Test',
        slots: const [],
      );
      final defaultSchedule = schedule.copyWith(isDefault: true);
      expect(defaultSchedule.isDefault, isTrue);
    });
  });

  group('AppSettings toMap and fromMap', () {
    test('should serialize and deserialize correctly', () {
      final settings = AppSettings(
        themeMode: ThemeMode.dark,
        totalWeeks: 20,
        semesterStartDate: DateTime(2026, 2, 17),
      );

      final map = settings.toMap();
      final restored = AppSettings.fromMap(map);

      expect(restored.themeMode, equals(ThemeMode.dark));
      expect(restored.totalWeeks, equals(20));
      expect(restored.semesterStartDate?.year, equals(2026));
    });

    test('should handle null semester start date', () {
      const settings = AppSettings();
      final map = settings.toMap();
      final restored = AppSettings.fromMap(map);
      expect(restored.semesterStartDate, isNull);
    });
  });

  group('TimeSchedule toMap and fromMap', () {
    test('should serialize and deserialize correctly', () {
      final schedule = TimeSchedule(
        id: 'test',
        name: 'Test',
        slots: const [
          TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
        ],
        isDefault: true,
      );

      final map = schedule.toMap();
      final restored = TimeSchedule.fromMap(map);

      expect(restored.id, equals('test'));
      expect(restored.name, equals('Test'));
      expect(restored.slots.length, equals(1));
      expect(restored.isDefault, isTrue);
    });
  });
}
