import 'dart:convert';

import '../database/db_helper.dart';
import '../models/models.dart';

class CourseScheduleRepository {
  final DatabaseHelper _dbHelper;

  CourseScheduleRepository(this._dbHelper);

  Future<List<CourseSchedule>> getSchedulesByCourseInfoId(
      String infoId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_schedules',
      where: 'course_info_id = ?',
      whereArgs: [infoId],
    );
    return maps.map((map) => CourseSchedule.fromMap(map)).toList();
  }

  Future<List<CourseScheduleWithInfo>> getSchedulesByWeek(
    String tableId,
    int week,
  ) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT cs.*, ci.id as ci_id, ci.course_table_id as ci_course_table_id,
             ci.name as ci_name, ci.credit as ci_credit, 
             ci.color_value as ci_color_value, ci.note as ci_note,
             ci.created_at as ci_created_at, ci.updated_at as ci_updated_at
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
    ''', [tableId]);

    return results
        .where((map) {
          final weeksJson = map['weeks'] as String;
          final weeks = List<int>.from(jsonDecode(weeksJson));
          return weeks.contains(week);
        })
        .map((map) {
          final schedule = CourseSchedule.fromMap(map);
          final info = CourseInfo(
            id: map['ci_id'] as String,
            courseTableId: map['ci_course_table_id'] as String,
            name: map['ci_name'] as String,
            credit: map['ci_credit'] as double?,
            colorValue: map['ci_color_value'] as int,
            note: map['ci_note'] as String?,
            createdAt: DateTime.fromMillisecondsSinceEpoch(map['ci_created_at'] as int),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(map['ci_updated_at'] as int),
          );
          return CourseScheduleWithInfo(schedule: schedule, info: info);
        })
        .toList();
  }

  Future<void> addSchedule(CourseSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.insert('course_schedules', schedule.toMap());
  }

  Future<void> updateSchedule(CourseSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<void> deleteSchedule(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
