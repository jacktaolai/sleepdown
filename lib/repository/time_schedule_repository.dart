import 'dart:convert';

import '../database/db_helper.dart';
import '../models/models.dart';

class TimeScheduleRepository {
  final DatabaseHelper _dbHelper;

  TimeScheduleRepository(this._dbHelper);

  Future<List<TimeSchedule>> getAllTimeSchedules() async {
    final db = await _dbHelper.database;
    final maps = await db.query('time_schedules');
    return maps.map((map) {
      return TimeSchedule(
        id: map['id'] as String,
        name: map['name'] as String,
        slots: (jsonDecode(map['slots'] as String) as List)
            .map((s) => TimeSlot.fromMap(s as Map<String, dynamic>))
            .toList(),
        isDefault: (map['is_default'] as int) == 1,
      );
    }).toList();
  }

  Future<TimeSchedule?> getTimeScheduleById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'time_schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final map = maps.first;
    return TimeSchedule(
      id: map['id'] as String,
      name: map['name'] as String,
      slots: (jsonDecode(map['slots'] as String) as List)
          .map((s) => TimeSlot.fromMap(s as Map<String, dynamic>))
          .toList(),
      isDefault: (map['is_default'] as int) == 1,
    );
  }

  Future<TimeSchedule?> getDefaultTimeSchedule() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'time_schedules',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final map = maps.first;
    return TimeSchedule(
      id: map['id'] as String,
      name: map['name'] as String,
      slots: (jsonDecode(map['slots'] as String) as List)
          .map((s) => TimeSlot.fromMap(s as Map<String, dynamic>))
          .toList(),
      isDefault: true,
    );
  }

  Future<void> addTimeSchedule(TimeSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.insert('time_schedules', {
      'id': schedule.id,
      'name': schedule.name,
      'slots': jsonEncode(schedule.slots.map((s) => s.toMap()).toList()),
      'is_default': schedule.isDefault ? 1 : 0,
    });
  }

  Future<void> updateTimeSchedule(TimeSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.update(
      'time_schedules',
      {
        'name': schedule.name,
        'slots': jsonEncode(schedule.slots.map((s) => s.toMap()).toList()),
        'is_default': schedule.isDefault ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<void> deleteTimeSchedule(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'time_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setDefaultTimeSchedule(String id) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'time_schedules',
        {'is_default': 0},
        where: 'is_default = ?',
        whereArgs: [1],
      );
      await txn.update(
        'time_schedules',
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
