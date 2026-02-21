import 'dart:convert';

enum WeekType { all, odd, even }

class WeekRange {
  final int start;
  final int end;
  final WeekType type;

  const WeekRange({
    required this.start,
    required this.end,
    this.type = WeekType.all,
  });

  bool contains(int week) {
    if (week < start || week > end) return false;
    switch (type) {
      case WeekType.all:
        return true;
      case WeekType.odd:
        return week % 2 == 1;
      case WeekType.even:
        return week % 2 == 0;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
      'type': type.index,
    };
  }

  factory WeekRange.fromMap(Map<String, dynamic> map) {
    return WeekRange(
      start: map['start'] as int,
      end: map['end'] as int,
      type: WeekType.values[map['type'] as int],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory WeekRange.fromJson(String source) {
    return WeekRange.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeekRange &&
        other.start == start &&
        other.end == end &&
        other.type == type;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode ^ type.hashCode;

  @override
  String toString() {
    String typeStr = '';
    if (type == WeekType.odd) typeStr = '单';
    if (type == WeekType.even) typeStr = '双';
    if (start == end) return '$start$typeStr';
    return '$start-$end$typeStr';
  }
}

class Course {
  final String id;
  final String name;
  final String teacher;
  final String location;
  final int dayOfWeek;
  final int startSection;
  final int endSection;
  final List<WeekRange> weekRanges;
  final int colorValue;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.name,
    this.teacher = '',
    this.location = '',
    required this.dayOfWeek,
    required this.startSection,
    required this.endSection,
    required this.weekRanges,
    this.colorValue = 0xFF3B82F6,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  bool isActiveInWeek(int week) {
    return weekRanges.any((range) => range.contains(week));
  }

  int get sectionCount => endSection - startSection + 1;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'location': location,
      'day_of_week': dayOfWeek,
      'start_section': startSection,
      'end_section': endSection,
      'week_ranges': jsonEncode(weekRanges.map((e) => e.toMap()).toList()),
      'color_value': colorValue,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    final weekRangesJson = map['week_ranges'] as String;
    final weekRangesList = jsonDecode(weekRangesJson) as List;
    
    return Course(
      id: map['id'] as String,
      name: map['name'] as String,
      teacher: map['teacher'] as String? ?? '',
      location: map['location'] as String? ?? '',
      dayOfWeek: map['day_of_week'] as int,
      startSection: map['start_section'] as int,
      endSection: map['end_section'] as int,
      weekRanges: weekRangesList
          .map((e) => WeekRange.fromMap(e as Map<String, dynamic>))
          .toList(),
      colorValue: map['color_value'] as int? ?? 0xFF3B82F6,
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Course copyWith({
    String? id,
    String? name,
    String? teacher,
    String? location,
    int? dayOfWeek,
    int? startSection,
    int? endSection,
    List<WeekRange>? weekRanges,
    int? colorValue,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      weekRanges: weekRanges ?? this.weekRanges,
      colorValue: colorValue ?? this.colorValue,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Course(id: $id, name: $name, dayOfWeek: $dayOfWeek, '
        'startSection: $startSection, endSection: $endSection)';
  }
}
