import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final String? currentCourseTableId;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.currentCourseTableId,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? currentCourseTableId,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currentCourseTableId: currentCourseTableId ?? this.currentCourseTableId,
    );
  }
}
