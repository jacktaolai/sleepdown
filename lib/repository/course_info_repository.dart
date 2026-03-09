import '../database/db_helper.dart';
import '../models/models.dart';

class CourseInfoRepository {
  final DatabaseHelper _dbHelper;

  CourseInfoRepository(this._dbHelper);

  Future<List<CourseInfo>> getCourseInfosByTableId(String tableId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_infos',
      where: 'course_table_id = ?',
      whereArgs: [tableId],
    );
    return maps.map((map) => CourseInfo.fromMap(map)).toList();
  }

  Future<CourseInfo?> getCourseInfoById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_infos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CourseInfo.fromMap(maps.first);
  }

  Future<void> addCourseInfo(CourseInfo info) async {
    final db = await _dbHelper.database;
    await db.insert('course_infos', info.toMap());
  }

  Future<void> updateCourseInfo(CourseInfo info) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_infos',
      info.toMap(),
      where: 'id = ?',
      whereArgs: [info.id],
    );
  }

  Future<void> deleteCourseInfo(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_infos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getAllTeachers(String tableId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT cs.teacher
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
      ORDER BY cs.teacher
    ''', [tableId]);
    return results.map((map) => map['teacher'] as String).toList();
  }

  Future<List<String>> getAllLocations(String tableId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT cs.location
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
      ORDER BY cs.location
    ''', [tableId]);
    return results.map((map) => map['location'] as String).toList();
  }

  Future<List<int>> getAllColors(String tableId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT color_value
      FROM course_infos
      WHERE course_table_id = ?
      ORDER BY color_value
    ''', [tableId]);
    return results.map((map) => map['color_value'] as int).toList();
  }
}
