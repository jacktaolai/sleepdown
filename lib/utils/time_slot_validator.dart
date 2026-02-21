import '../models/time_schedule.dart';

class TimeSlotValidator {
  static String? validate(List<TimeSlot> slots) {
    if (slots.isEmpty) return '请至少添加一个节次';

    final sortedSlots = List<TimeSlot>.from(slots)
      ..sort((a, b) => a.section.compareTo(b.section));

    for (int i = 0; i < sortedSlots.length; i++) {
      final slot = sortedSlots[i];

      if (!slot.isValid) {
        return '第${slot.section}节：开始时间必须早于结束时间';
      }

      if (i > 0) {
        final prev = sortedSlots[i - 1];
        final prevEnd = prev.endHour * 60 + prev.endMinute;
        final currStart = slot.startHour * 60 + slot.startMinute;
        if (currStart < prevEnd) {
          return '第${slot.section}节开始时间早于上一节结束时间';
        }
      }
    }
    return null;
  }

  static bool isValid(List<TimeSlot> slots) {
    return validate(slots) == null;
  }

  static String? validateSectionNumber(int section, List<TimeSlot> slots) {
    if (section < 1) return '节次必须大于0';
    if (slots.any((s) => s.section == section)) {
      return '第$section节已存在';
    }
    return null;
  }

  static String? validateTime(int hour, int minute) {
    if (hour < 0 || hour > 23) return '小时必须在0-23之间';
    if (minute < 0 || minute > 59) return '分钟必须在0-59之间';
    return null;
  }
}
