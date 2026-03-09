import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repository/course_table_repository.dart';
import 'database_helper_provider.dart';
import 'settings_provider.dart';

class CourseTableState {
  final CourseTable? table;
  final bool isLoading;
  final String? error;

  const CourseTableState({
    this.table,
    this.isLoading = false,
    this.error,
  });

  CourseTableState copyWith({
    CourseTable? table,
    bool? isLoading,
    String? error,
  }) {
    return CourseTableState(
      table: table ?? this.table,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CourseTableNotifier extends StateNotifier<CourseTableState> {
  final CourseTableRepository _repository;
  String? _tableId;

  CourseTableNotifier(this._repository, this._tableId) : super(const CourseTableState()) {
    _loadCourseTable();
  }

  Future<void> _loadCourseTable() async {
    if (_tableId == null) {
      state = const CourseTableState();
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final table = await _repository.getCourseTableById(_tableId!);
      state = CourseTableState(table: table);
    } catch (e) {
      state = CourseTableState(error: e.toString());
    }
  }

  Future<void> switchCourseTable(String tableId) async {
    _tableId = tableId;
    await _loadCourseTable();
  }

  Future<void> updateCourseTable(CourseTable table) async {
    await _repository.updateCourseTable(table);
    state = CourseTableState(table: table);
  }

  Future<void> addCourseTable(CourseTable table) async {
    await _repository.addCourseTable(table);
    _tableId = table.id;
    await _loadCourseTable();
  }

  Future<void> deleteCourseTable(String id) async {
    await _repository.deleteCourseTable(id);
    if (_tableId == id) {
      _tableId = null;
      state = const CourseTableState();
    }
  }
}

final courseTableProvider = StateNotifierProvider<CourseTableNotifier, CourseTableState>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  final settings = ref.watch(settingsProvider);
  return CourseTableNotifier(CourseTableRepository(dbHelper), settings.currentCourseTableId);
});
