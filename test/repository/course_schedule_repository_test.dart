import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;
  late CourseTableRepository tableRepo;
  late CourseInfoRepository infoRepo;
  late CourseScheduleRepository repository;

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.execute('PRAGMA foreign_keys = ON');
    await db.delete('course_schedules');
    await db.delete('course_infos');
    await db.delete('course_tables');
    
    tableRepo = CourseTableRepository(dbHelper);
    infoRepo = CourseInfoRepository(dbHelper);
    repository = CourseScheduleRepository(dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('CourseScheduleRepository', () {
    late String tableId;
    late String infoId;

    setUp(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final table = CourseTable(
        id: 'table_$now',
        name: '测试课程表',
        semesterStartDate: DateTime(2026, 2, 23),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await tableRepo.addCourseTable(table);
      tableId = table.id;

      final info = CourseInfo(
        id: 'info_$now',
        courseTableId: tableId,
        name: '数据结构',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await infoRepo.addCourseInfo(info);
      infoId = info.id;
    });

    test('addSchedule adds new schedule', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final schedule = CourseSchedule(
        id: 'schedule_$now',
        courseInfoId: infoId,
        teacher: '张三',
        location: 'A301',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 2, 3, 4, 5, 6, 7, 8],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addSchedule(schedule);
      final schedules = await repository.getSchedulesByCourseInfoId(infoId);
      
      expect(schedules, isNotEmpty);
      expect(schedules.first.teacher, '张三');
      
      await repository.deleteSchedule('schedule_$now');
    });

    test('getSchedulesByWeek returns schedules for specific week', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final schedule = CourseSchedule(
        id: 'week_$now',
        courseInfoId: infoId,
        teacher: '李四',
        location: 'B201',
        dayOfWeek: 1,
        startSection: 3,
        endSection: 4,
        weeks: [1, 2, 3],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addSchedule(schedule);

      final week1 = await repository.getSchedulesByWeek(tableId, 1);
      expect(week1, isNotEmpty);
      
      final week5 = await repository.getSchedulesByWeek(tableId, 5);
      expect(week5, isEmpty);
      
      await repository.deleteSchedule('week_$now');
    });

    test('time mode schedule works correctly', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final schedule = CourseSchedule(
        id: 'time_$now',
        courseInfoId: infoId,
        teacher: '王五',
        location: 'C101',
        dayOfWeek: 2,
        startHour: 14,
        startMinute: 30,
        endHour: 16,
        endMinute: 0,
        weeks: [1, 2, 3, 4, 5],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(schedule.useTimeMode, true);
      expect(schedule.timeDisplayText, '14:30-16:00');

      await repository.addSchedule(schedule);
      
      final schedules = await repository.getSchedulesByWeek(tableId, 1);
      expect(schedules.first.schedule.useTimeMode, true);
      
      await repository.deleteSchedule('time_$now');
    });

    test('deleteSchedule removes schedule', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final schedule = CourseSchedule(
        id: 'delete_$now',
        courseInfoId: infoId,
        teacher: '待删除',
        location: 'D301',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 2, 3],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addSchedule(schedule);
      await repository.deleteSchedule('delete_$now');
      
      final schedules = await repository.getSchedulesByCourseInfoId(infoId);
      expect(schedules, isEmpty);
    });

    test('isActiveInWeek returns correct value', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final schedule = CourseSchedule(
        id: 'active_$now',
        courseInfoId: infoId,
        teacher: '赵六',
        location: 'D301',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 3, 5, 7],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(schedule.isActiveInWeek(1), true);
      expect(schedule.isActiveInWeek(2), false);
      expect(schedule.isActiveInWeek(3), true);
      expect(schedule.isActiveInWeek(4), false);
      expect(schedule.isActiveInWeek(5), true);
    });
  });

  group('Cascade Delete', () {
    test('deleting course info cascades to schedules', () async {
      final db = await dbHelper.database;
      await db.execute('PRAGMA foreign_keys = ON');
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final table = CourseTable(
        id: 'cascade_$now',
        name: '级联测试',
        semesterStartDate: DateTime(2026, 2, 23),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await tableRepo.addCourseTable(table);

      final info = CourseInfo(
        id: 'cascade_info_$now',
        courseTableId: table.id,
        name: '级联课程',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await infoRepo.addCourseInfo(info);

      final schedule = CourseSchedule(
        id: 'cascade_schedule_$now',
        courseInfoId: info.id,
        teacher: '教师',
        location: '地点',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 2, 3],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.addSchedule(schedule);

      var schedules = await repository.getSchedulesByCourseInfoId(info.id);
      expect(schedules, isNotEmpty);

      await infoRepo.deleteCourseInfo(info.id);
      schedules = await repository.getSchedulesByCourseInfoId(info.id);
      expect(schedules, isEmpty);
      
      await tableRepo.deleteCourseTable(table.id);
    });
  });
}
