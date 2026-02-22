import '../models/course.dart';
import '../database/db_helper.dart';

abstract class CourseRepository {
  Future<List<Course>> getAllCourses();
  Future<List<Course>> getCoursesByWeek(int week);
  Future<List<Course>> getCoursesByDay(int dayOfWeek);
  Future<Course?> getCourseById(String id);
  Future<void> addCourse(Course course);
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(String id);
  Future<void> close();
}

class CourseRepositoryImpl implements CourseRepository {
  final DatabaseHelper _dbHelper;

  CourseRepositoryImpl(this._dbHelper);

  @override
  Future<List<Course>> getAllCourses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  @override
  Future<List<Course>> getCoursesByWeek(int week) async {
    final allCourses = await getAllCourses();
    return allCourses.where((course) => course.isActiveInWeek(week)).toList();
  }

  @override
  Future<List<Course>> getCoursesByDay(int dayOfWeek) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'day_of_week = ?',
      whereArgs: [dayOfWeek],
    );
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  @override
  Future<Course?> getCourseById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Course.fromMap(maps.first);
  }

  @override
  Future<void> addCourse(Course course) async {
    final db = await _dbHelper.database;
    await db.insert('courses', course.toMap());
  }

  @override
  Future<void> updateCourse(Course course) async {
    final db = await _dbHelper.database;
    await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  @override
  Future<void> deleteCourse(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> close() async {
    await _dbHelper.close();
  }
}
