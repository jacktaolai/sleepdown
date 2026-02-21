import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../repository/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  throw UnimplementedError('courseRepositoryProvider must be overridden');
});

final courseListProvider = StateNotifierProvider<CourseNotifier, List<Course>>((ref) {
  final repository = ref.watch(courseRepositoryProvider);
  return CourseNotifier(repository);
});

class CourseNotifier extends StateNotifier<List<Course>> {
  final CourseRepository _repository;

  CourseNotifier(this._repository) : super([]) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    state = await _repository.getAllCourses();
  }

  List<Course> getCoursesByWeek(int week) {
    return state.where((course) => course.isActiveInWeek(week)).toList();
  }

  List<Course> getCoursesByDay(int week, int dayOfWeek) {
    return getCoursesByWeek(week)
        .where((course) => course.dayOfWeek == dayOfWeek)
        .toList();
  }

  Future<void> addCourse(Course course) async {
    await _repository.addCourse(course);
    state = [...state, course];
  }

  Future<void> updateCourse(Course course) async {
    await _repository.updateCourse(course);
    state = state.map((c) => c.id == course.id ? course : c).toList();
  }

  Future<void> deleteCourse(String id) async {
    await _repository.deleteCourse(id);
    state = state.where((c) => c.id != id).toList();
  }

  Course? getCourseById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool hasConflict(Course course) {
    for (final existing in state) {
      if (existing.id == course.id) continue;
      if (existing.dayOfWeek != course.dayOfWeek) continue;
      if (existing.weekRanges.any((r) =>
          course.weekRanges.any((cr) =>
              _hasSectionOverlap(
                existing.startSection,
                existing.endSection,
                course.startSection,
                course.endSection,
              ) &&
              _hasWeekOverlap(existing.weekRanges, course.weekRanges)))) {
        return true;
      }
    }
    return false;
  }

  bool _hasSectionOverlap(int start1, int end1, int start2, int end2) {
    return start1 <= end2 && end1 >= start2;
  }

  bool _hasWeekOverlap(List<WeekRange> ranges1, List<WeekRange> ranges2) {
    for (final r1 in ranges1) {
      for (final r2 in ranges2) {
        if (r1.start <= r2.end && r1.end >= r2.start) {
          final overlapWeeks = _getOverlapWeeks(r1, r2);
          if (overlapWeeks.isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  List<int> _getOverlapWeeks(WeekRange r1, WeekRange r2) {
    final start = r1.start > r2.start ? r1.start : r2.start;
    final end = r1.end < r2.end ? r1.end : r2.end;
    if (start > end) return [];

    final weeks = <int>[];
    for (var week = start; week <= end; week++) {
      if (r1.contains(week) && r2.contains(week)) {
        weeks.add(week);
      }
    }
    return weeks;
  }
}
