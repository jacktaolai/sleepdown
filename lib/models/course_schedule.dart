import 'dart:convert';

import 'course_info.dart';

class CourseSchedule {
  final String id;
  final String courseInfoId;
  final String teacher;
  final String location;
  final int dayOfWeek;
  final int? startSection;
  final int? endSection;
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;
  final List<int> weeks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseSchedule({
    required this.id,
    required this.courseInfoId,
    required this.teacher,
    required this.location,
    required this.dayOfWeek,
    this.startSection,
    this.endSection,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
    required this.weeks,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get useTimeMode => startSection == null;

  int? get sectionCount =>
      startSection != null && endSection != null
          ? endSection! - startSection! + 1
          : null;

  String get timeDisplayText {
    if (useTimeMode) {
      return '${startHour!.toString().padLeft(2, '0')}:${startMinute!.toString().padLeft(2, '0')}-'
          '${endHour!.toString().padLeft(2, '0')}:${endMinute!.toString().padLeft(2, '0')}';
    }
    return '第$startSection-$endSection节';
  }

  bool isActiveInWeek(int week) => weeks.contains(week);

  CourseSchedule copyWith({
    String? id,
    String? courseInfoId,
    String? teacher,
    String? location,
    int? dayOfWeek,
    int? startSection,
    int? endSection,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    List<int>? weeks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseSchedule(
      id: id ?? this.id,
      courseInfoId: courseInfoId ?? this.courseInfoId,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      weeks: weeks ?? this.weeks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_info_id': courseInfoId,
      'teacher': teacher,
      'location': location,
      'day_of_week': dayOfWeek,
      'start_section': startSection,
      'end_section': endSection,
      'start_hour': startHour,
      'start_minute': startMinute,
      'end_hour': endHour,
      'end_minute': endMinute,
      'weeks': jsonEncode(weeks),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CourseSchedule.fromMap(Map<String, dynamic> map) {
    return CourseSchedule(
      id: map['id'] as String,
      courseInfoId: map['course_info_id'] as String,
      teacher: map['teacher'] as String,
      location: map['location'] as String,
      dayOfWeek: map['day_of_week'] as int,
      startSection: map['start_section'] as int?,
      endSection: map['end_section'] as int?,
      startHour: map['start_hour'] as int?,
      startMinute: map['start_minute'] as int?,
      endHour: map['end_hour'] as int?,
      endMinute: map['end_minute'] as int?,
      weeks: List<int>.from(jsonDecode(map['weeks'] as String)),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}

class CourseScheduleWithInfo {
  final CourseSchedule schedule;
  final CourseInfo info;

  const CourseScheduleWithInfo({
    required this.schedule,
    required this.info,
  });
}
