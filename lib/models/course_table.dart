class CourseTable {
  final String id;
  final String name;
  final DateTime semesterStartDate;
  final int totalWeeks;
  final String timeScheduleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseTable({
    required this.id,
    required this.name,
    required this.semesterStartDate,
    this.totalWeeks = 18,
    required this.timeScheduleId,
    required this.createdAt,
    required this.updatedAt,
  });

  CourseTable copyWith({
    String? id,
    String? name,
    DateTime? semesterStartDate,
    int? totalWeeks,
    String? timeScheduleId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseTable(
      id: id ?? this.id,
      name: name ?? this.name,
      semesterStartDate: semesterStartDate ?? this.semesterStartDate,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      timeScheduleId: timeScheduleId ?? this.timeScheduleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'semester_start_date': semesterStartDate.millisecondsSinceEpoch,
      'total_weeks': totalWeeks,
      'time_schedule_id': timeScheduleId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CourseTable.fromMap(Map<String, dynamic> map) {
    return CourseTable(
      id: map['id'] as String,
      name: map['name'] as String,
      semesterStartDate:
          DateTime.fromMillisecondsSinceEpoch(map['semester_start_date'] as int),
      totalWeeks: map['total_weeks'] as int? ?? 18,
      timeScheduleId: map['time_schedule_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
