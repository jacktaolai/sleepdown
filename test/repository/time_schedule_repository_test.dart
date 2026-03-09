import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/time_schedule_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;
  late TimeScheduleRepository repository;

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.execute('PRAGMA foreign_keys = ON');
    await db.delete('time_schedules');
    await db.insert('time_schedules', {
      'id': 'default',
      'name': '默认作息',
      'slots': '[{"section":1,"startHour":8,"startMinute":0,"endHour":8,"endMinute":45}]',
      'is_default': 1,
    });
    repository = TimeScheduleRepository(dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('TimeScheduleRepository', () {
    test('getDefaultTimeSchedule returns default schedule', () async {
      final schedule = await repository.getDefaultTimeSchedule();
      
      expect(schedule, isNotNull);
      expect(schedule!.name, '默认作息');
      expect(schedule.isDefault, true);
    });

    test('getAllTimeSchedules returns all schedules', () async {
      final schedules = await repository.getAllTimeSchedules();
      
      expect(schedules, isNotEmpty);
    });

    test('addTimeSchedule adds new schedule', () async {
      final schedule = TimeSchedule(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        name: '测试作息',
        slots: [
          const TimeSlot(
            section: 1,
            startHour: 8,
            startMinute: 0,
            endHour: 8,
            endMinute: 45,
          ),
        ],
        isDefault: false,
      );

      await repository.addTimeSchedule(schedule);
      final result = await repository.getTimeScheduleById(schedule.id);
      
      expect(result, isNotNull);
      expect(result!.name, '测试作息');
      
      await repository.deleteTimeSchedule(schedule.id);
    });

    test('setDefaultTimeSchedule changes default', () async {
      final newSchedule = TimeSchedule(
        id: 'new_default_${DateTime.now().millisecondsSinceEpoch}',
        name: '新默认作息',
        slots: [
          const TimeSlot(
            section: 1,
            startHour: 9,
            startMinute: 0,
            endHour: 9,
            endMinute: 45,
          ),
        ],
        isDefault: false,
      );

      await repository.addTimeSchedule(newSchedule);
      await repository.setDefaultTimeSchedule(newSchedule.id);
      
      final result = await repository.getDefaultTimeSchedule();
      expect(result!.id, newSchedule.id);
      
      await repository.setDefaultTimeSchedule('default');
      await repository.deleteTimeSchedule(newSchedule.id);
    });

    test('deleteTimeSchedule removes schedule', () async {
      final schedule = TimeSchedule(
        id: 'to_delete_${DateTime.now().millisecondsSinceEpoch}',
        name: '待删除',
        slots: [
          const TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
        ],
      );
      
      await repository.addTimeSchedule(schedule);
      await repository.deleteTimeSchedule(schedule.id);
      
      final result = await repository.getTimeScheduleById(schedule.id);
      expect(result, isNull);
    });
  });
}
