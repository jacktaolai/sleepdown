import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/time_schedule.dart';
import 'package:sleepdown/utils/time_slot_validator.dart';

void main() {
  group('TimeSlotValidator', () {
    test('should return error for empty slots', () {
      expect(TimeSlotValidator.validate([]), equals('请至少添加一个节次'));
    });

    test('should return null for valid slots', () {
      final slots = [
        const TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
        const TimeSlot(section: 2, startHour: 8, startMinute: 50, endHour: 9, endMinute: 35),
      ];

      expect(TimeSlotValidator.validate(slots), isNull);
    });

    test('should return error for invalid time slot', () {
      final slots = [
        const TimeSlot(section: 1, startHour: 9, startMinute: 0, endHour: 8, endMinute: 45),
      ];

      expect(
        TimeSlotValidator.validate(slots),
        contains('开始时间必须早于结束时间'),
      );
    });

    test('should return error for overlapping time slots', () {
      final slots = [
        const TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 50),
        const TimeSlot(section: 2, startHour: 8, startMinute: 45, endHour: 9, endMinute: 35),
      ];

      expect(
        TimeSlotValidator.validate(slots),
        contains('开始时间早于上一节结束时间'),
      );
    });

    test('should check isValid correctly', () {
      final validSlots = [
        const TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
      ];

      expect(TimeSlotValidator.isValid(validSlots), isTrue);

      final invalidSlots = [
        const TimeSlot(section: 1, startHour: 9, startMinute: 0, endHour: 8, endMinute: 45),
      ];

      expect(TimeSlotValidator.isValid(invalidSlots), isFalse);
    });

    test('should validate section number', () {
      final existingSlots = [
        const TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
      ];

      expect(
        TimeSlotValidator.validateSectionNumber(1, existingSlots),
        contains('已存在'),
      );

      expect(
        TimeSlotValidator.validateSectionNumber(2, existingSlots),
        isNull,
      );

      expect(
        TimeSlotValidator.validateSectionNumber(0, existingSlots),
        contains('必须大于0'),
      );
    });

    test('should validate time', () {
      expect(TimeSlotValidator.validateTime(8, 30), isNull);
      expect(TimeSlotValidator.validateTime(24, 0), contains('小时'));
      expect(TimeSlotValidator.validateTime(8, 60), contains('分钟'));
    });
  });
}
