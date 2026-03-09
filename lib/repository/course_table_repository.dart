import '../database/db_helper.dart';
import '../models/course_table.dart';

/// 课程表数据仓库接口
abstract class CourseTableRepository {
  /// 获取所有课程表
  Future<List<CourseTable>> getAllCourseTables();

  /// 根据 ID 获取课程表
  Future<CourseTable?> getCourseTableById(String id);

  /// 获取当前使用的课程表
  Future<CourseTable?> getCurrentCourseTable();

  /// 添加课程表
  Future<void> addCourseTable(CourseTable table);

  /// 更新课程表
  Future<void> updateCourseTable(CourseTable table);

  /// 删除课程表
  Future<void> deleteCourseTable(String id);
}

/// 课程表仓库实现类
class CourseTableRepositoryImpl implements CourseTableRepository {
  final DatabaseHelper _dbHelper;

  CourseTableRepositoryImpl(this._dbHelper);

  @override
  Future<List<CourseTable>> getAllCourseTables() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('course_tables', orderBy: 'created_at DESC');
    return maps.map((map) => CourseTable.fromMap(map)).toList();
  }

  @override
  Future<CourseTable?> getCourseTableById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'course_tables',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CourseTable.fromMap(maps.first);
  }

  @override
  Future<CourseTable?> getCurrentCourseTable() async {
    final tables = await getAllCourseTables();
    if (tables.isEmpty) return null;
    return tables.first;
  }

  @override
  Future<void> addCourseTable(CourseTable table) async {
    final db = await _dbHelper.database;
    await db.insert('course_tables', table.toMap());
  }

  @override
  Future<void> updateCourseTable(CourseTable table) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_tables',
      table.toMap(),
      where: 'id = ?',
      whereArgs: [table.id],
    );
  }

  @override
  Future<void> deleteCourseTable(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_tables',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
