import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final DateTime? semesterStartDate;
  final int totalWeeks;
  final int currentSemester;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.semesterStartDate,
    this.totalWeeks = 18,
    this.currentSemester = 1,
  });

  bool get hasSemesterStartDate => semesterStartDate != null;

  Map<String, dynamic> toMap() {
    return {
      'theme_mode': themeMode.index,
      'semester_start_date': semesterStartDate?.millisecondsSinceEpoch,
      'total_weeks': totalWeeks,
      'current_semester': currentSemester,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeMode.values[map['theme_mode'] as int? ?? 0],
      semesterStartDate: map['semester_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['semester_start_date'] as int)
          : null,
      totalWeeks: map['total_weeks'] as int? ?? 18,
      currentSemester: map['current_semester'] as int? ?? 1,
    );
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    DateTime? semesterStartDate,
    bool clearSemesterStartDate = false,
    int? totalWeeks,
    int? currentSemester,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      semesterStartDate: clearSemesterStartDate 
          ? null 
          : (semesterStartDate ?? this.semesterStartDate),
      totalWeeks: totalWeeks ?? this.totalWeeks,
      currentSemester: currentSemester ?? this.currentSemester,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.semesterStartDate == semesterStartDate &&
        other.totalWeeks == totalWeeks &&
        other.currentSemester == currentSemester;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        semesterStartDate.hashCode ^
        totalWeeks.hashCode ^
        currentSemester.hashCode;
  }

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, '
        'semesterStartDate: $semesterStartDate, '
        'totalWeeks: $totalWeeks, '
        'currentSemester: $currentSemester)';
  }
}
