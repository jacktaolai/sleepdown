import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('should have default values', () {
      const settings = AppSettings();

      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.semesterStartDate, isNull);
      expect(settings.totalWeeks, equals(18));
      expect(settings.currentSemester, equals(1));
    });

    test('should check hasSemesterStartDate correctly', () {
      const withoutDate = AppSettings();
      expect(withoutDate.hasSemesterStartDate, isFalse);

      final withDate = AppSettings(
        semesterStartDate: DateTime(2026, 2, 17),
      );
      expect(withDate.hasSemesterStartDate, isTrue);
    });

    test('should serialize and deserialize correctly', () {
      final settings = AppSettings(
        themeMode: ThemeMode.dark,
        semesterStartDate: DateTime(2026, 2, 17),
        totalWeeks: 20,
        currentSemester: 2,
      );

      final map = settings.toMap();
      final fromMap = AppSettings.fromMap(map);

      expect(fromMap.themeMode, equals(settings.themeMode));
      expect(fromMap.semesterStartDate, equals(settings.semesterStartDate));
      expect(fromMap.totalWeeks, equals(settings.totalWeeks));
      expect(fromMap.currentSemester, equals(settings.currentSemester));
    });

    test('should copy with new values', () {
      const original = AppSettings();
      final updated = original.copyWith(
        themeMode: ThemeMode.light,
        totalWeeks: 20,
      );

      expect(updated.themeMode, equals(ThemeMode.light));
      expect(updated.totalWeeks, equals(20));
      expect(updated.currentSemester, equals(original.currentSemester));
    });

    test('should clear semester start date', () {
      final withDate = AppSettings(
        semesterStartDate: DateTime(2026, 2, 17),
      );

      final cleared = withDate.copyWith(clearSemesterStartDate: true);

      expect(cleared.semesterStartDate, isNull);
    });
  });
}
