import 'course_info.dart';
import 'course_schedule.dart';

/// 课程视图模型 - 用于 UI 显示的课程数据组合
///
/// 组合了 CourseInfo（课程基本信息）和 CourseSchedule（课程安排）
/// 提供与原有 Course 模型兼容的接口
class CourseViewModel {
  final String id;
  final String courseInfoId;
  final String name;
  final String teacher;
  final String location;
  final int dayOfWeek;
  final int startSection;
  final int endSection;
  final List<int> weeks;
  final int colorValue;
  final String? note;
  final double? credit;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 时间模式字段
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;

  const CourseViewModel({
    required this.id,
    required this.courseInfoId,
    required this.name,
    required this.teacher,
    required this.location,
    required this.dayOfWeek,
    required this.startSection,
    required this.endSection,
    required this.weeks,
    required this.colorValue,
    this.note,
    this.credit,
    required this.createdAt,
    required this.updatedAt,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  });

  /// 从 CourseInfo 和 CourseSchedule 组合创建
  factory CourseViewModel.fromInfoAndSchedule(
    CourseInfo info,
    CourseSchedule schedule,
  ) {
    return CourseViewModel(
      id: schedule.id,
      courseInfoId: info.id,
      name: info.name,
      teacher: schedule.teacher,
      location: schedule.location,
      dayOfWeek: schedule.dayOfWeek,
      startSection: schedule.startSection ?? 1,
      endSection: schedule.endSection ?? 1,
      weeks: schedule.weeks,
      colorValue: info.colorValue,
      note: info.note,
      credit: info.credit,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
      startHour: schedule.startHour,
      startMinute: schedule.startMinute,
      endHour: schedule.endHour,
      endMinute: schedule.endMinute,
    );
  }

  /// 是否使用时间模式
  bool get useTimeMode => startHour != null;

  /// 判断课程是否在指定周次有效
  bool isActiveInWeek(int week) {
    return weeks.contains(week);
  }

  /// 获取课程时长的节次数
  int get sectionCount => endSection - startSection + 1;

  /// 获取时间显示文本
  String get timeDisplayText {
    if (useTimeMode) {
      return '${startHour!.toString().padLeft(2, '0')}:'
          '${startMinute!.toString().padLeft(2, '0')}-'
          '${endHour!.toString().padLeft(2, '0')}:'
          '${endMinute!.toString().padLeft(2, '0')}';
    }
    return '第$startSection-$endSection节';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_info_id': courseInfoId,
      'name': name,
      'teacher': teacher,
      'location': location,
      'day_of_week': dayOfWeek,
      'start_section': startSection,
      'end_section': endSection,
      'weeks': weeks,
      'color_value': colorValue,
      'note': note,
      'credit': credit,
      'start_hour': startHour,
      'start_minute': startMinute,
      'end_hour': endHour,
      'end_minute': endMinute,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  CourseViewModel copyWith({
    String? id,
    String? courseInfoId,
    String? name,
    String? teacher,
    String? location,
    int? dayOfWeek,
    int? startSection,
    int? endSection,
    List<int>? weeks,
    int? colorValue,
    String? note,
    double? credit,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return CourseViewModel(
      id: id ?? this.id,
      courseInfoId: courseInfoId ?? this.courseInfoId,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      weeks: weeks ?? this.weeks,
      colorValue: colorValue ?? this.colorValue,
      note: note ?? this.note,
      credit: credit ?? this.credit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseViewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CourseViewModel(id: $id, name: $name, dayOfWeek: $dayOfWeek, '
        'startSection: $startSection, endSection: $endSection)';
  }
}
