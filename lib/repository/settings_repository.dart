import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/time_schedule.dart';
import '../database/db_helper.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<TimeSchedule?> getTimeSchedule();
  Future<TimeSchedule?> getTimeScheduleById(String id);
  Future<List<TimeSchedule>> getAllTimeSchedules();
  Future<void> updateTimeSchedule(TimeSchedule schedule);
  Future<void> addTimeSchedule(TimeSchedule schedule);
  Future<void> deleteTimeSchedule(String id);
  Future<void> setDefaultTimeSchedule(String id);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final DatabaseHelper _dbHelper;
  static const String _settingsKey = 'app_settings';

  SettingsRepositoryImpl(this._dbHelper);

  @override
  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson == null) {
      return const AppSettings();
    }
    return AppSettings.fromMap(jsonDecode(settingsJson) as Map<String, dynamic>);
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
  }

  @override
  Future<TimeSchedule?> getTimeSchedule() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_schedules',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isEmpty) {
      final allSchedules = await getAllTimeSchedules();
      return allSchedules.isNotEmpty ? allSchedules.first : null;
    }
    return TimeSchedule.fromMap(maps.first);
  }

  @override
  Future<TimeSchedule?> getTimeScheduleById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TimeSchedule.fromMap(maps.first);
  }

  @override
  Future<List<TimeSchedule>> getAllTimeSchedules() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('time_schedules');
    return maps.map((map) => TimeSchedule.fromMap(map)).toList();
  }

  @override
  Future<void> updateTimeSchedule(TimeSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.update(
      'time_schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  @override
  Future<void> addTimeSchedule(TimeSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.insert('time_schedules', schedule.toMap());
  }

  @override
  Future<void> deleteTimeSchedule(String id) async {
    final db = await _dbHelper.database;
    final schedule = await getTimeScheduleById(id);
    final isDeletingDefault = schedule?.isDefault ?? false;

    await db.delete(
      'time_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (isDeletingDefault) {
      final remaining = await getAllTimeSchedules();
      if (remaining.isNotEmpty) {
        await setDefaultTimeSchedule(remaining.first.id);
      }
    }
  }

  @override
  Future<void> setDefaultTimeSchedule(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'time_schedules',
      {'is_default': 0},
    );
    await db.update(
      'time_schedules',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
