import 'dart:convert';

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

  String get startTimeString {
    return '${startHour.toString().padLeft(2, '0')}:'
        '${startMinute.toString().padLeft(2, '0')}';
  }

  String get endTimeString {
    return '${endHour.toString().padLeft(2, '0')}:'
        '${endMinute.toString().padLeft(2, '0')}';
  }

  bool get isValid {
    return (startHour * 60 + startMinute) < (endHour * 60 + endMinute);
  }

  int get durationMinutes {
    return (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
  }

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

  TimeSlot copyWith({
    int? section,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return TimeSlot(
      section: section ?? this.section,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot &&
        other.section == section &&
        other.startHour == startHour &&
        other.startMinute == startMinute &&
        other.endHour == endHour &&
        other.endMinute == endMinute;
  }

  @override
  int get hashCode {
    return section.hashCode ^
        startHour.hashCode ^
        startMinute.hashCode ^
        endHour.hashCode ^
        endMinute.hashCode;
  }

  @override
  String toString() {
    return 'TimeSlot(section: $section, $startTimeString-$endTimeString)';
  }
}

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

  TimeSlot? getSlotBySection(int section) {
    try {
      return slots.firstWhere((slot) => slot.section == section);
    } catch (_) {
      return null;
    }
  }

  int get maxSection {
    if (slots.isEmpty) return 0;
    return slots.map((s) => s.section).reduce((a, b) => a > b ? a : b);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slots': jsonEncode(slots.map((e) => e.toMap()).toList()),
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory TimeSchedule.fromMap(Map<String, dynamic> map) {
    final slotsJson = map['slots'] as String;
    final slotsList = jsonDecode(slotsJson) as List;
    
    return TimeSchedule(
      id: map['id'] as String,
      name: map['name'] as String,
      slots: slotsList
          .map((e) => TimeSlot.fromMap(e as Map<String, dynamic>))
          .toList(),
      isDefault: (map['is_default'] as int?) == 1,
    );
  }

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TimeSchedule(id: $id, name: $name, slots: ${slots.length})';
  }
}
