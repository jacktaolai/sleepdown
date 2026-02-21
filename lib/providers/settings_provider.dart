import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../models/time_schedule.dart';
import '../repository/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('settingsRepositoryProvider must be overridden');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

final timeScheduleProvider = StateNotifierProvider<TimeScheduleNotifier, TimeSchedule?>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return TimeScheduleNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = await _repository.getSettings();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final newSettings = state.copyWith(themeMode: mode);
    await _repository.updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateTotalWeeks(int weeks) async {
    final newSettings = state.copyWith(totalWeeks: weeks);
    await _repository.updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateSemesterStartDate(DateTime date) async {
    final newSettings = state.copyWith(semesterStartDate: date);
    await _repository.updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _repository.updateSettings(settings);
    state = settings;
  }
}

class TimeScheduleNotifier extends StateNotifier<TimeSchedule?> {
  final SettingsRepository _repository;

  TimeScheduleNotifier(this._repository) : super(null) {
    _loadTimeSchedule();
  }

  Future<void> _loadTimeSchedule() async {
    state = await _repository.getTimeSchedule();
  }

  Future<void> loadTimeSchedule() async {
    state = await _repository.getTimeSchedule();
  }

  Future<void> loadTimeScheduleById(String id) async {
    state = await _repository.getTimeScheduleById(id);
  }

  Future<void> addTimeSchedule(TimeSchedule schedule) async {
    await _repository.addTimeSchedule(schedule);
  }

  Future<void> updateTimeSchedule(TimeSchedule schedule) async {
    await _repository.updateTimeSchedule(schedule);
    if (state?.id == schedule.id) {
      state = schedule;
    }
  }

  Future<void> deleteTimeSchedule(String id) async {
    await _repository.deleteTimeSchedule(id);
    if (state?.id == id) {
      await loadTimeSchedule();
    }
  }

  Future<void> setDefaultTimeSchedule(String id) async {
    await _repository.setDefaultTimeSchedule(id);
    await loadTimeSchedule();
  }
}
