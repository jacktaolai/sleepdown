class TimeSchedule {
  final String id;
  final String name;
  final List<TimeSlot> slots;
  final bool isDefault;

  const TimeSchedule({
    required this.id,
    required this.name,
    required this.slots,
    this.isDefault = false,
  });

  TimeSchedule copyWith({
    String? id,
    String? name,
    List<TimeSlot>? slots,
    bool? isDefault,
  }) {
    return TimeSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      slots: slots ?? this.slots,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slots': slots.map((s) => s.toMap()).toList(),
      'isDefault': isDefault,
    };
  }

  factory TimeSchedule.fromMap(Map<String, dynamic> map) {
    return TimeSchedule(
      id: map['id'] as String,
      name: map['name'] as String,
      slots: (map['slots'] as List)
          .map((s) => TimeSlot.fromMap(s as Map<String, dynamic>))
          .toList(),
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }
}

class TimeSlot {
  final int section;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const TimeSlot({
    required this.section,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  String get startTimeString =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get endTimeString =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  bool get isValid =>
      (startHour * 60 + startMinute) < (endHour * 60 + endMinute);

  Map<String, dynamic> toMap() {
    return {
      'section': section,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      section: map['section'] as int,
      startHour: map['startHour'] as int,
      startMinute: map['startMinute'] as int,
      endHour: map['endHour'] as int,
      endMinute: map['endMinute'] as int,
    );
  }
}
