import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sleepdown/providers/settings_provider.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/settings_repository.dart';

void main() {
  group('AppSettings Model', () {
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

  group('SettingsNotifier', () {
    test('should initialize with default settings', () async {
      final notifier = SettingsNotifier(_MockSettingsRepository());
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(notifier.state.themeMode, ThemeMode.system);
      expect(notifier.state.currentCourseTableId, isNull);
    });

    test('setCurrentCourseTable should update state', () async {
      final notifier = SettingsNotifier(_MockSettingsRepository());
      await Future.delayed(const Duration(milliseconds: 50));
      
      await notifier.setCurrentCourseTable('new_table_id');
      
      expect(notifier.state.currentCourseTableId, 'new_table_id');
    });

    test('setThemeMode should update state', () async {
      final notifier = SettingsNotifier(_MockSettingsRepository());
      await Future.delayed(const Duration(milliseconds: 50));
      
      await notifier.setThemeMode(ThemeMode.dark);
      
      expect(notifier.state.themeMode, ThemeMode.dark);
    });
  });
}

class _MockSettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings();
  
  @override
  Future<AppSettings> getSettings() async => _settings;
  
  @override
  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
  }
}
