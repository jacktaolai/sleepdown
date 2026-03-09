class CourseInfo {
  final String id;
  final String courseTableId;
  final String name;
  final double? credit;
  final int colorValue;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseInfo({
    required this.id,
    required this.courseTableId,
    required this.name,
    this.credit,
    required this.colorValue,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  CourseInfo copyWith({
    String? id,
    String? courseTableId,
    String? name,
    double? credit,
    int? colorValue,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseInfo(
      id: id ?? this.id,
      courseTableId: courseTableId ?? this.courseTableId,
      name: name ?? this.name,
      credit: credit ?? this.credit,
      colorValue: colorValue ?? this.colorValue,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_table_id': courseTableId,
      'name': name,
      'credit': credit,
      'color_value': colorValue,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CourseInfo.fromMap(Map<String, dynamic> map) {
    return CourseInfo(
      id: map['id'] as String,
      courseTableId: map['course_table_id'] as String,
      name: map['name'] as String,
      credit: map['credit'] as double?,
      colorValue: map['color_value'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
