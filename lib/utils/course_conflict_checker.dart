import '../models/course.dart';

class CourseConflictChecker {
  static List<Course> checkConflict(Course newCourse, List<Course> existingCourses) {
    return existingCourses.where((existing) {
      if (existing.id == newCourse.id) return false;
      if (existing.dayOfWeek != newCourse.dayOfWeek) return false;

      final sectionOverlap = !(newCourse.endSection < existing.startSection ||
          newCourse.startSection > existing.endSection);
      if (!sectionOverlap) return false;

      for (int week = 1; week <= 25; week++) {
        if (newCourse.isActiveInWeek(week) && existing.isActiveInWeek(week)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  static bool hasConflict(Course newCourse, List<Course> existingCourses) {
    return checkConflict(newCourse, existingCourses).isNotEmpty;
  }

  static List<Course> checkConflictsForWeek(
    Course newCourse,
    List<Course> existingCourses,
    int week,
  ) {
    return existingCourses.where((existing) {
      if (existing.id == newCourse.id) return false;
      if (existing.dayOfWeek != newCourse.dayOfWeek) return false;
      if (!existing.isActiveInWeek(week)) return false;
      if (!newCourse.isActiveInWeek(week)) return false;

      return !(newCourse.endSection < existing.startSection ||
          newCourse.startSection > existing.endSection);
    }).toList();
  }
}
