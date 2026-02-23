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

/// 课程仓库实现类，负责与本地SQLite数据库交互，执行课程相关的CRUD操作。
class CourseRepositoryImpl implements CourseRepository {
  final DatabaseHelper _dbHelper;

  /// 构造函数，依赖注入，等价于传参并赋值给_dbHelper
  /// 
  /// * [dbHelper] 数据库帮助类单例
  CourseRepositoryImpl(this._dbHelper);

  /// 获取数据库中所有课程的列表。
  ///
  /// 从本地SQLite数据库的`courses`表中查询所有课程记录，
  /// 并将每条记录的`Map<String, dynamic>`格式转换为强类型的[Course]实体对象。
  ///
  /// **返回值**：
  /// - 成功：返回包含所有课程的[List<Course>]（无数据时返回空列表）；
  @override
  Future<List<Course>> getAllCourses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  /// 获取数据库中指定周数的课程列表。
  ///
  /// 从本地SQLite数据库的`courses`表中查询所有课程记录，
  /// 并筛选出在指定周数内有冲突的课程（即与指定周数有重叠的课程）。
  ///
  /// **参数**：
  /// - [week]：要查询的周数（从1开始）。
  ///
  /// **返回值**：
  /// - 成功：返回包含指定周数内课程的[List<Course>]（无数据时返回空列表）；
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
