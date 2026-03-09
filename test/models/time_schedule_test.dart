import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/models.dart';

void main() {
  group('TimeSlot', () {
    test('startTimeString returns formatted time', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );
      
      expect(slot.startTimeString, '08:00');
    });

    test('endTimeString returns formatted time', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );
      
      expect(slot.endTimeString, '08:45');
    });

    test('isValid returns true when start is before end', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );
      
      expect(slot.isValid, true);
    });

    test('isValid returns false when start is after end', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 9,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );
      
      expect(slot.isValid, false);
    });

    test('isValid returns false when start equals end', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 0,
      );
      
      expect(slot.isValid, false);
    });

    test('toMap and fromMap work correctly', () {
      const slot = TimeSlot(
        section: 1,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 45,
      );
      
      final map = slot.toMap();
      final restored = TimeSlot.fromMap(map);
      
      expect(restored.section, slot.section);
      expect(restored.startHour, slot.startHour);
      expect(restored.startMinute, slot.startMinute);
      expect(restored.endHour, slot.endHour);
      expect(restored.endMinute, slot.endMinute);
    });
  });

  group('TimeSchedule', () {
    test('toMap and fromMap work correctly', () {
      const schedule = TimeSchedule(
        id: 'test_id',
        name: '测试作息',
        slots: [
          TimeSlot(
            section: 1,
            startHour: 8,
            startMinute: 0,
            endHour: 8,
            endMinute: 45,
          ),
        ],
        isDefault: true,
      );
      
      final map = schedule.toMap();
      final restored = TimeSchedule.fromMap(map);
      
      expect(restored.id, schedule.id);
      expect(restored.name, schedule.name);
      expect(restored.slots.length, schedule.slots.length);
      expect(restored.isDefault, schedule.isDefault);
    });

    test('copyWith works correctly', () {
      const schedule = TimeSchedule(
        id: 'test_id',
        name: '原始名称',
        slots: [],
        isDefault: false,
      );
      
      final updated = schedule.copyWith(name: '新名称', isDefault: true);
      
      expect(updated.id, 'test_id');
      expect(updated.name, '新名称');
      expect(updated.isDefault, true);
    });
  });
}
