import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'course_info.dart';

/// 课程安排 - 具体的上课时间和地点
///
/// 支持两种时间输入模式（互斥）：
/// - 节次模式：使用 startSection/endSection
/// - 时间模式：使用 startHour/startMinute/endHour/endMinute
class CourseSchedule {
  final String id;
  final String courseInfoId;
  final String teacher;
  final String location;
  final int dayOfWeek;
  final List<int> weeks;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ========== 节次模式字段（时间模式时为 null）==========
  final int? startSection;
  final int? endSection;

  // ========== 时间模式字段（节次模式时为 null）==========
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;

  const CourseSchedule({
    required this.id,
    required this.courseInfoId,
    required this.teacher,
    required this.location,
    required this.dayOfWeek,
    required this.weeks,
    required this.createdAt,
    required this.updatedAt,
    this.startSection,
    this.endSection,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  });

  /// 是否使用时间模式
  /// 当 startSection 为 null 时，表示使用时间模式
  bool get useTimeMode => startSection == null;

  /// 判断该安排在指定周次是否有效
  bool isActiveInWeek(int week) => weeks.contains(week);

  /// 获取课程时长的节次数（仅节次模式有效）
  int? get sectionCount =>
      startSection != null && endSection != null
          ? endSection! - startSection! + 1
          : null;

  /// 获取时间显示文本
  /// 节次模式：显示 "第3-4节"
  /// 时间模式：显示 "14:30-16:00"
  String get timeDisplayText {
    if (useTimeMode) {
      return '${startHour!.toString().padLeft(2, '0')}:${startMinute!.toString().padLeft(2, '0')}-'
          '${endHour!.toString().padLeft(2, '0')}:${endMinute!.toString().padLeft(2, '0')}';
    }
    return '第$startSection-$endSection节';
  }

  /// 创建新的课程安排（节次模式）
  factory CourseSchedule.createSectionMode({
    required String courseInfoId,
    required String teacher,
    required String location,
    required int dayOfWeek,
    required List<int> weeks,
    required int startSection,
    required int endSection,
  }) {
    final now = DateTime.now();
    return CourseSchedule(
      id: const Uuid().v4(),
      courseInfoId: courseInfoId,
      teacher: teacher,
      location: location,
      dayOfWeek: dayOfWeek,
      weeks: weeks,
      startSection: startSection,
      endSection: endSection,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 创建新的课程安排（时间模式）
  factory CourseSchedule.createTimeMode({
    required String courseInfoId,
    required String teacher,
    required String location,
    required int dayOfWeek,
    required List<int> weeks,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) {
    final now = DateTime.now();
    return CourseSchedule(
      id: const Uuid().v4(),
      courseInfoId: courseInfoId,
      teacher: teacher,
      location: location,
      dayOfWeek: dayOfWeek,
      weeks: weeks,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      createdAt: now,
      updatedAt: now,
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
    final weeksJson = map['weeks'] as String;
    final weeksList = jsonDecode(weeksJson) as List;

    return CourseSchedule(
      id: map['id'] as String,
      courseInfoId: map['course_info_id'] as String,
      teacher: map['teacher'] as String? ?? '',
      location: map['location'] as String? ?? '',
      dayOfWeek: map['day_of_week'] as int,
      startSection: map['start_section'] as int?,
      endSection: map['end_section'] as int?,
      startHour: map['start_hour'] as int?,
      startMinute: map['start_minute'] as int?,
      endHour: map['end_hour'] as int?,
      endMinute: map['end_minute'] as int?,
      weeks: weeksList.map((e) => e as int).toList(),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  CourseSchedule copyWith({
    String? id,
    String? courseInfoId,
    String? teacher,
    String? location,
    int? dayOfWeek,
    List<int>? weeks,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? startSection,
    int? endSection,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return CourseSchedule(
      id: id ?? this.id,
      courseInfoId: courseInfoId ?? this.courseInfoId,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      weeks: weeks ?? this.weeks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CourseSchedule(id: $id, courseInfoId: $courseInfoId, dayOfWeek: $dayOfWeek, teacher: $teacher, location: $location)';
  }
}

/// 课程安排与课程信息的组合（用于展示）
class CourseScheduleWithInfo {
  final CourseSchedule schedule;
  final CourseInfo info;

  const CourseScheduleWithInfo({
    required this.schedule,
    required this.info,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseScheduleWithInfo &&
        other.schedule.id == schedule.id;
  }

  @override
  int get hashCode => schedule.id.hashCode;
}
