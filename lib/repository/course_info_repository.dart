import '../database/db_helper.dart';
import '../models/course_info.dart';

/// 课程信息数据仓库接口
abstract class CourseInfoRepository {
  /// 获取指定课程表的所有课程信息
  Future<List<CourseInfo>> getCourseInfosByTableId(String tableId);

  /// 根据 ID 获取课程信息
  Future<CourseInfo?> getCourseInfoById(String id);

  /// 添加课程信息
  Future<void> addCourseInfo(CourseInfo info);

  /// 更新课程信息
  Future<void> updateCourseInfo(CourseInfo info);

  /// 删除课程信息
  Future<void> deleteCourseInfo(String id);

  // ========== 聚合查询接口 ==========

  /// 获取指定课程表中所有唯一的教师名称
  Future<List<String>> getAllTeachers(String tableId);

  /// 获取指定课程表中所有唯一的上课地点
  Future<List<String>> getAllLocations(String tableId);

  /// 获取指定课程表中所有使用过的颜色值
  Future<List<int>> getAllColors(String tableId);
}

/// 课程信息仓库实现类
class CourseInfoRepositoryImpl implements CourseInfoRepository {
  final DatabaseHelper _dbHelper;

  CourseInfoRepositoryImpl(this._dbHelper);

  @override
  Future<List<CourseInfo>> getCourseInfosByTableId(String tableId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'course_infos',
      where: 'course_table_id = ?',
      whereArgs: [tableId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => CourseInfo.fromMap(map)).toList();
  }

  @override
  Future<CourseInfo?> getCourseInfoById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'course_infos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CourseInfo.fromMap(maps.first);
  }

  @override
  Future<void> addCourseInfo(CourseInfo info) async {
    final db = await _dbHelper.database;
    await db.insert('course_infos', info.toMap());
  }

  @override
  Future<void> updateCourseInfo(CourseInfo info) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_infos',
      info.toMap(),
      where: 'id = ?',
      whereArgs: [info.id],
    );
  }

  @override
  Future<void> deleteCourseInfo(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_infos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<String>> getAllTeachers(String tableId) async {
    final db = await _dbHelper.database;
    // 通过 course_schedules 和 course_infos 关联查询
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT cs.teacher
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
      AND cs.teacher != ''
      ORDER BY cs.teacher ASC
    ''', [tableId]);
    return maps.map((map) => map['teacher'] as String).toList();
  }

  @override
  Future<List<String>> getAllLocations(String tableId) async {
    final db = await _dbHelper.database;
    // 通过 course_schedules 和 course_infos 关联查询
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT cs.location
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
      AND cs.location != ''
      ORDER BY cs.location ASC
    ''', [tableId]);
    return maps.map((map) => map['location'] as String).toList();
  }

  @override
  Future<List<int>> getAllColors(String tableId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT color_value
      FROM course_infos
      WHERE course_table_id = ?
      ORDER BY color_value ASC
    ''', [tableId]);
    return maps.map((map) => map['color_value'] as int).toList();
  }
}
