import '../database/db_helper.dart';
import '../models/course_info.dart';
import '../models/course_schedule.dart';
import '../models/course_view_model.dart';

/// 课程安排数据仓库接口
abstract class CourseScheduleRepository {
  /// 获取指定课程信息的所有安排
  Future<List<CourseSchedule>> getSchedulesByCourseInfoId(String infoId);

  /// 获取指定课程表在某周的所有课程安排
  /// 用于周视图展示
  Future<List<CourseScheduleWithInfo>> getSchedulesByWeek(
    String tableId,
    int week,
  );

  /// 获取指定课程表在某周的所有课程安排（返回视图模型）
  /// 用于周视图展示
  Future<List<CourseViewModel>> getCourseViewModelsByWeek(
    String tableId,
    int week,
  );

  /// 获取指定课程表的所有课程安排（返回视图模型）
  Future<List<CourseViewModel>> getAllCourseViewModels(String tableId);

  /// 添加课程安排
  Future<void> addSchedule(CourseSchedule schedule);

  /// 更新课程安排
  Future<void> updateSchedule(CourseSchedule schedule);

  /// 删除课程安排
  Future<void> deleteSchedule(String id);
}

/// 课程安排仓库实现类
class CourseScheduleRepositoryImpl implements CourseScheduleRepository {
  final DatabaseHelper _dbHelper;

  CourseScheduleRepositoryImpl(this._dbHelper);

  @override
  Future<List<CourseSchedule>> getSchedulesByCourseInfoId(
      String infoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'course_schedules',
      where: 'course_info_id = ?',
      whereArgs: [infoId],
    );
    return maps.map((map) => CourseSchedule.fromMap(map)).toList();
  }

  @override
  Future<List<CourseScheduleWithInfo>> getSchedulesByWeek(
    String tableId,
    int week,
  ) async {
    final db = await _dbHelper.database;

    // 查询指定课程表在指定周次的所有课程安排及其课程信息
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        cs.*,
        ci.id as ci_id,
        ci.course_table_id,
        ci.name as ci_name,
        ci.credit,
        ci.color_value,
        ci.note as ci_note,
        ci.created_at as ci_created_at,
        ci.updated_at as ci_updated_at
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
    ''', [tableId]);

    final result = <CourseScheduleWithInfo>[];

    for (final map in maps) {
      final schedule = CourseSchedule.fromMap(map);

      // 检查该安排是否在指定周次有效
      if (schedule.isActiveInWeek(week)) {
        final info = CourseInfo(
          id: map['ci_id'] as String,
          courseTableId: map['course_table_id'] as String,
          name: map['ci_name'] as String,
          credit: map['credit'] as double?,
          colorValue: map['color_value'] as int,
          note: map['ci_note'] as String?,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
              map['ci_created_at'] as int),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
              map['ci_updated_at'] as int),
        );

        result.add(CourseScheduleWithInfo(
          schedule: schedule,
          info: info,
        ));
      }
    }

    return result;
  }

  @override
  Future<List<CourseViewModel>> getCourseViewModelsByWeek(
    String tableId,
    int week,
  ) async {
    final schedulesWithInfo = await getSchedulesByWeek(tableId, week);
    return schedulesWithInfo
        .map((s) => CourseViewModel.fromInfoAndSchedule(s.info, s.schedule))
        .toList();
  }

  @override
  Future<List<CourseViewModel>> getAllCourseViewModels(String tableId) async {
    final db = await _dbHelper.database;

    // 查询指定课程表的所有课程安排及其课程信息
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        cs.*,
        ci.id as ci_id,
        ci.course_table_id,
        ci.name as ci_name,
        ci.credit,
        ci.color_value,
        ci.note as ci_note,
        ci.created_at as ci_created_at,
        ci.updated_at as ci_updated_at
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
    ''', [tableId]);

    final result = <CourseViewModel>[];

    for (final map in maps) {
      final schedule = CourseSchedule.fromMap(map);
      final info = CourseInfo(
        id: map['ci_id'] as String,
        courseTableId: map['course_table_id'] as String,
        name: map['ci_name'] as String,
        credit: map['credit'] as double?,
        colorValue: map['color_value'] as int,
        note: map['ci_note'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['ci_created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(map['ci_updated_at'] as int),
      );

      result.add(CourseViewModel.fromInfoAndSchedule(info, schedule));
    }

    return result;
  }

  @override
  Future<void> addSchedule(CourseSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.insert('course_schedules', schedule.toMap());
  }

  @override
  Future<void> updateSchedule(CourseSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  @override
  Future<void> deleteSchedule(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
