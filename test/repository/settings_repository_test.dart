import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/repository/settings_repository.dart';
import 'package:sleepdown/models/app_settings.dart';
import 'package:sleepdown/models/time_schedule.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<void> cleanDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFile = p.join(dbPath, 'sleepdown.db');
    final file = File(dbFile);
    if (await file.exists()) {
      await file.delete();
    }
  }

  group('SettingsRepository', () {
    late DatabaseHelper dbHelper;
    late SettingsRepository repository;

    setUp(() async {
      await cleanDatabase();
      SharedPreferences.setMockInitialValues({});
      dbHelper = DatabaseHelper();
      repository = SettingsRepositoryImpl(dbHelper);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    group('AppSettings', () {
      test('should get default settings', () async {
        final settings = await repository.getSettings();
        expect(settings.themeMode, equals(ThemeMode.system));
        expect(settings.totalWeeks, equals(18));
      });

      test('should update settings', () async {
        final newSettings = AppSettings(
          themeMode: ThemeMode.dark,
          totalWeeks: 20,
          semesterStartDate: DateTime(2026, 2, 17),
        );

        await repository.updateSettings(newSettings);
        final settings = await repository.getSettings();

        expect(settings.themeMode, equals(ThemeMode.dark));
        expect(settings.totalWeeks, equals(20));
        expect(settings.semesterStartDate, equals(DateTime(2026, 2, 17)));
      });

      test('should persist settings across instances', () async {
        final settings = AppSettings(
          themeMode: ThemeMode.light,
          totalWeeks: 16,
        );

        await repository.updateSettings(settings);

        final newRepository = SettingsRepositoryImpl(dbHelper);
        final loaded = await newRepository.getSettings();

        expect(loaded.themeMode, equals(ThemeMode.light));
        expect(loaded.totalWeeks, equals(16));
      });
    });

    group('TimeSchedule', () {
      test('should get default time schedule', () async {
        final schedule = await repository.getTimeSchedule();
        expect(schedule, isNotNull);
        expect(schedule!.name, equals('默认作息时间'));
        expect(schedule.isDefault, isTrue);
      });

      test('should get all time schedules', () async {
        final schedules = await repository.getAllTimeSchedules();
        expect(schedules.length, greaterThanOrEqualTo(1));
      });

      test('should add new time schedule', () async {
        final newSchedule = TimeSchedule(
          id: 'custom-schedule',
          name: '自定义作息',
          slots: const [
            TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
          ],
        );

        await repository.addTimeSchedule(newSchedule);
        final schedules = await repository.getAllTimeSchedules();

        expect(schedules.length, greaterThanOrEqualTo(2));
      });

      test('should get time schedule by id', () async {
        final schedule = await repository.getTimeScheduleById('default');
        expect(schedule, isNotNull);
        expect(schedule!.name, equals('默认作息时间'));
      });

      test('should update time schedule', () async {
        final schedule = await repository.getTimeSchedule();
        expect(schedule, isNotNull);

        final updated = schedule!.copyWith(name: '更新后的作息');
        await repository.updateTimeSchedule(updated);

        final loaded = await repository.getTimeScheduleById('default');
        expect(loaded!.name, equals('更新后的作息'));
      });

      test('should set default time schedule', () async {
        final newSchedule = TimeSchedule(
          id: 'new-default',
          name: '新默认作息',
          slots: const [
            TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 50),
          ],
        );

        await repository.addTimeSchedule(newSchedule);
        await repository.setDefaultTimeSchedule('new-default');

        final defaultSchedule = await repository.getTimeSchedule();
        expect(defaultSchedule!.id, equals('new-default'));
        expect(defaultSchedule.isDefault, isTrue);
      });

      test('should delete time schedule and reassign default', () async {
        final newSchedule = TimeSchedule(
          id: 'to-delete',
          name: '待删除作息',
          slots: const [
            TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
          ],
          isDefault: true,
        );

        await repository.addTimeSchedule(newSchedule);
        await repository.deleteTimeSchedule('to-delete');

        final schedules = await repository.getAllTimeSchedules();
        expect(schedules.any((s) => s.id == 'to-delete'), isFalse);

        final defaultSchedule = await repository.getTimeSchedule();
        expect(defaultSchedule, isNotNull);
      });
    });
  });
}
