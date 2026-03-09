import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/providers/time_schedule_provider.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/time_schedule_repository.dart';

void main() {
  group('TimeScheduleNotifier', () {
    test('initial state should be loading', () {
      final notifier = TimeScheduleNotifier(_MockTimeScheduleRepository());
      
      expect(notifier.state.isLoading, true);
    });

    test('addTimeSchedule should update state', () async {
      final notifier = TimeScheduleNotifier(_MockTimeScheduleRepository());
      final schedule = TimeSchedule(
        id: 'test_1',
        name: '测试作息',
        slots: const [TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45)],
        isDefault: true,
      );
      
      await notifier.addTimeSchedule(schedule);
      
      expect(notifier.state.isLoading, false);
    });

    test('updateTimeSchedule should update state', () async {
      final notifier = TimeScheduleNotifier(_MockTimeScheduleRepository());
      final schedule = TimeSchedule(
        id: 'test_1',
        name: '更新作息',
        slots: const [TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45)],
        isDefault: true,
      );
      
      await notifier.updateTimeSchedule(schedule);
      
      expect(notifier.state.isLoading, false);
    });

    test('deleteTimeSchedule should update state', () async {
      final notifier = TimeScheduleNotifier(_MockTimeScheduleRepository());
      
      await notifier.deleteTimeSchedule('test_1');
      
      expect(notifier.state.isLoading, false);
    });

    test('setDefault should update state', () async {
      final notifier = TimeScheduleNotifier(_MockTimeScheduleRepository());
      
      await notifier.setDefault('test_1');
      
      expect(notifier.state.isLoading, false);
    });
  });
}

class _MockTimeScheduleRepository implements TimeScheduleRepository {
  @override
  Future<List<TimeSchedule>> getAllTimeSchedules() async => [];
  
  @override
  Future<TimeSchedule?> getTimeScheduleById(String id) async => null;
  
  @override
  Future<TimeSchedule?> getDefaultTimeSchedule() async => null;
  
  @override
  Future<void> addTimeSchedule(TimeSchedule schedule) async {}
  
  @override
  Future<void> updateTimeSchedule(TimeSchedule schedule) async {}
  
  @override
  Future<void> deleteTimeSchedule(String id) async {}
  
  @override
  Future<void> setDefaultTimeSchedule(String id) async {}
}
