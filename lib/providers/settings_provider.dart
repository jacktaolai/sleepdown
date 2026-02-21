import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../models/time_schedule.dart';
import '../repository/settings_repository.dart';
import '../database/db_helper.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.read(databaseHelperProvider));
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});

final timeScheduleProvider =
    StateNotifierProvider<TimeScheduleNotifier, AsyncValue<TimeSchedule?>>((ref) {
  return TimeScheduleNotifier(ref.read(settingsRepositoryProvider));
});

final allTimeSchedulesProvider =
    StateNotifierProvider<AllTimeSchedulesNotifier, AsyncValue<List<TimeSchedule>>>((ref) {
  return AllTimeSchedulesNotifier(ref.read(settingsRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      await _repository.updateSettings(settings);
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(themeMode: mode));
  }

  Future<void> setSemesterStartDate(DateTime? date) async {
    final current = state.valueOrNull ?? const AppSettings();
    if (date == null) {
      await updateSettings(current.copyWith(clearSemesterStartDate: true));
    } else {
      await updateSettings(current.copyWith(semesterStartDate: date));
    }
  }

  Future<void> setTotalWeeks(int weeks) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(totalWeeks: weeks));
  }

  Future<void> setCurrentSemester(int semester) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(currentSemester: semester));
  }
}

class TimeScheduleNotifier extends StateNotifier<AsyncValue<TimeSchedule?>> {
  final SettingsRepository _repository;

  TimeScheduleNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTimeSchedule();
  }

  Future<void> loadTimeSchedule() async {
    state = const AsyncValue.loading();
    try {
      final schedule = await _repository.getTimeSchedule();
      state = AsyncValue.data(schedule);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTimeSchedule(TimeSchedule schedule) async {
    try {
      await _repository.updateTimeSchedule(schedule);
      state = AsyncValue.data(schedule);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setDefaultTimeSchedule(String id) async {
    try {
      await _repository.setDefaultTimeSchedule(id);
      final schedule = await _repository.getTimeSchedule();
      state = AsyncValue.data(schedule);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class AllTimeSchedulesNotifier extends StateNotifier<AsyncValue<List<TimeSchedule>>> {
  final SettingsRepository _repository;

  AllTimeSchedulesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTimeSchedules();
  }

  Future<void> loadTimeSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _repository.getAllTimeSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTimeSchedule(TimeSchedule schedule) async {
    try {
      await _repository.addTimeSchedule(schedule);
      final schedules = await _repository.getAllTimeSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTimeSchedule(String id) async {
    try {
      await _repository.deleteTimeSchedule(id);
      final schedules = await _repository.getAllTimeSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
