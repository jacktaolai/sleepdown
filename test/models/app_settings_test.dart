import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sleepdown/models/models.dart';

void main() {
  group('AppSettings', () {
    test('initial state should have default values', () {
      const settings = AppSettings();
      
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.currentCourseTableId, isNull);
    });

    test('copyWith should update themeMode', () {
      const settings = AppSettings();
      final newSettings = settings.copyWith(themeMode: ThemeMode.dark);
      
      expect(newSettings.themeMode, ThemeMode.dark);
      expect(newSettings.currentCourseTableId, isNull);
    });

    test('copyWith should update currentCourseTableId', () {
      const settings = AppSettings();
      final newSettings = settings.copyWith(currentCourseTableId: 'table_123');
      
      expect(newSettings.currentCourseTableId, 'table_123');
      expect(newSettings.themeMode, ThemeMode.system);
    });

    test('copyWith should update both fields', () {
      const settings = AppSettings();
      final newSettings = settings.copyWith(
        themeMode: ThemeMode.light,
        currentCourseTableId: 'table_456',
      );
      
      expect(newSettings.themeMode, ThemeMode.light);
      expect(newSettings.currentCourseTableId, 'table_456');
    });
  });
}
