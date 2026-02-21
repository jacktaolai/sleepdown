import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/time_schedule.dart';

void main() {
  group('TimeSlot', () {
    test('should format time strings correctly', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );

      expect(slot.startTimeString, equals('08:00'));
      expect(slot.endTimeString, equals('08:45'));
    });

    test('should validate time correctly', () {
      const validSlot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );
      expect(validSlot.isValid, isTrue);

      const invalidSlot = TimeSlot(
        section: 1,
        startHour: 9,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );
      expect(invalidSlot.isValid, isFalse);
    });

    test('should calculate duration correctly', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );
      expect(slot.durationMinutes, equals(45));
    });

    test('should serialize and deserialize correctly', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );

      final map = slot.toMap();
      final fromMap = TimeSlot.fromMap(map);

      expect(fromMap.section, equals(slot.section));
      expect(fromMap.startHour, equals(slot.startHour));
      expect(fromMap.startMinute, equals(slot.startMinute));
      expect(fromMap.endHour, equals(slot.endHour));
      expect(fromMap.endMinute, equals(slot.endMinute));
    });
  });

  group('TimeSchedule', () {
    final testSchedule = TimeSchedule(
      id: 'test-schedule',
      name: '测试作息',
      slots: const [
        TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
        TimeSlot(section: 2, startHour: 8, startMinute: 50, endHour: 9, endMinute: 35),
      ],
      isDefault: true,
    );

    test('should get slot by section', () {
      final slot = testSchedule.getSlotBySection(1);
      expect(slot, isNotNull);
      expect(slot!.section, equals(1));

      final notFound = testSchedule.getSlotBySection(99);
      expect(notFound, isNull);
    });

    test('should calculate max section', () {
      expect(testSchedule.maxSection, equals(2));
    });

    test('should serialize and deserialize correctly', () {
      final map = testSchedule.toMap();
      final fromMap = TimeSchedule.fromMap(map);

      expect(fromMap.id, equals(testSchedule.id));
      expect(fromMap.name, equals(testSchedule.name));
      expect(fromMap.slots.length, equals(testSchedule.slots.length));
      expect(fromMap.isDefault, equals(testSchedule.isDefault));
    });

    test('should copy with new values', () {
      final updated = testSchedule.copyWith(name: '更新作息');

      expect(updated.id, equals(testSchedule.id));
      expect(updated.name, equals('更新作息'));
    });
  });
}
