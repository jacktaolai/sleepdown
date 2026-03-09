import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class SettingsRepository {
  static const String _themeModeKey = 'theme_mode';
  static const String _currentCourseTableIdKey = 'current_course_table_id';

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    final themeMode = ThemeMode.values[themeModeIndex];
    final currentCourseTableId = prefs.getString(_currentCourseTableIdKey);
    
    return AppSettings(
      themeMode: themeMode,
      currentCourseTableId: currentCourseTableId,
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_themeModeKey, settings.themeMode.index);
    
    if (settings.currentCourseTableId != null) {
      await prefs.setString(_currentCourseTableIdKey, settings.currentCourseTableId!);
    } else {
      await prefs.remove(_currentCourseTableIdKey);
    }
  }
}
