import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repository/time_schedule_repository.dart';
import 'database_helper_provider.dart';

class TimeScheduleNotifier extends StateNotifier<AsyncValue<List<TimeSchedule>>> {
  final TimeScheduleRepository _repository;

  TimeScheduleNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTimeSchedules();
  }

  Future<void> _loadTimeSchedules() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllTimeSchedules());
  }

  Future<void> addTimeSchedule(TimeSchedule schedule) async {
    await _repository.addTimeSchedule(schedule);
    await _loadTimeSchedules();
  }

  Future<void> updateTimeSchedule(TimeSchedule schedule) async {
    await _repository.updateTimeSchedule(schedule);
    await _loadTimeSchedules();
  }

  Future<void> deleteTimeSchedule(String id) async {
    await _repository.deleteTimeSchedule(id);
    await _loadTimeSchedules();
  }

  Future<void> setDefault(String id) async {
    await _repository.setDefaultTimeSchedule(id);
    await _loadTimeSchedules();
  }
}

final timeScheduleProvider = StateNotifierProvider<TimeScheduleNotifier, AsyncValue<List<TimeSchedule>>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TimeScheduleNotifier(TimeScheduleRepository(dbHelper));
});
