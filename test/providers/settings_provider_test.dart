import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sleepdown/providers/settings_provider.dart';

void main() {
  group('SettingsNotifier', () {
    test('initial state should have default values', () {
      final notifier = SettingsNotifier();
      
      expect(notifier.state.themeMode, ThemeMode.system);
      expect(notifier.state.currentCourseTableId, isNull);
    });

    test('setCurrentCourseTable should update state', () async {
      final notifier = SettingsNotifier();
      
      await notifier.setCurrentCourseTable('test_table_id');
      
      expect(notifier.state.currentCourseTableId, 'test_table_id');
    });

    test('setThemeMode should update theme', () async {
      final notifier = SettingsNotifier();
      
      await notifier.setThemeMode(ThemeMode.dark);
      
      expect(notifier.state.themeMode, ThemeMode.dark);
    });

    test('setThemeMode to light should work', () async {
      final notifier = SettingsNotifier();
      
      await notifier.setThemeMode(ThemeMode.light);
      
      expect(notifier.state.themeMode, ThemeMode.light);
    });

    test('setThemeMode to system should work', () async {
      final notifier = SettingsNotifier();
      
      await notifier.setThemeMode(ThemeMode.system);
      
      expect(notifier.state.themeMode, ThemeMode.system);
    });
  });
}
