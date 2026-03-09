import '../database/db_helper.dart';
import '../models/models.dart';

class CourseTableRepository {
  final DatabaseHelper _dbHelper;

  CourseTableRepository(this._dbHelper);

  Future<List<CourseTable>> getAllCourseTables() async {
    final db = await _dbHelper.database;
    final maps = await db.query('course_tables');
    return maps.map((map) => CourseTable.fromMap(map)).toList();
  }

  Future<CourseTable?> getCourseTableById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_tables',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CourseTable.fromMap(maps.first);
  }

  Future<void> addCourseTable(CourseTable table) async {
    final db = await _dbHelper.database;
    await db.insert('course_tables', table.toMap());
  }

  Future<void> updateCourseTable(CourseTable table) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_tables',
      table.toMap(),
      where: 'id = ?',
      whereArgs: [table.id],
    );
  }

  Future<void> deleteCourseTable(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_tables',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
