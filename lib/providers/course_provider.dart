import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/course.dart';
import '../repository/course_repository.dart';
import '../database/db_helper.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl(ref.read(databaseHelperProvider));
});

final courseListProvider =
    StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  return CourseNotifier(ref.read(courseRepositoryProvider));
});

class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final CourseRepository _repository;

  CourseNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    state = const AsyncValue.loading();
    try {
      final courses = await _repository.getAllCourses();
      state = AsyncValue.data(courses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<Course> getCoursesByWeek(int week) {
    return state.valueOrNull?.where((c) => c.isActiveInWeek(week)).toList() ?? [];
  }

  List<Course> getCoursesByDay(int dayOfWeek) {
    return state.valueOrNull?.where((c) => c.dayOfWeek == dayOfWeek).toList() ?? [];
  }

  List<Course> getCoursesByDayAndWeek(int dayOfWeek, int week) {
    return state.valueOrNull
            ?.where((c) => c.dayOfWeek == dayOfWeek && c.isActiveInWeek(week))
            .toList() ??
        [];
  }

  Future<void> addCourse(Course course) async {
    try {
      final newCourse = course.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.addCourse(newCourse);
      state = AsyncValue.data([...?state.valueOrNull, newCourse]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      final updatedCourse = course.copyWith(
        updatedAt: DateTime.now(),
      );
      await _repository.updateCourse(updatedCourse);
      state = AsyncValue.data(
        state.valueOrNull
                ?.map((c) => c.id == course.id ? updatedCourse : c)
                .toList() ??
            [],
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCourse(String id) async {
    try {
      await _repository.deleteCourse(id);
      state =
          AsyncValue.data(state.valueOrNull?.where((c) => c.id != id).toList() ?? []);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Course? getCourseById(String id) {
    try {
      return state.valueOrNull?.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
