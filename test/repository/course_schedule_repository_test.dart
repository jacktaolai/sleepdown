import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/repository/course_schedule_repository.dart';
import 'package:sleepdown/models/course_schedule.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<void> cleanDatabase() async {
    try {
      // 关闭默认的数据库连接
      try {
        DatabaseHelper().close();
      } catch (_) {}

      // 删除数据库文件
      final dbPath = await getDatabasesPath();
      final dbFile = p.join(dbPath, 'sleepdown.db');
      final file = File(dbFile);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (e) {
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            await file.delete();
          } catch (_) {}
        }
      }

      // 删除缓存目录
      final cacheDir = p.join(dbPath, '..', '.dart_tool', 'sqflite_common_ffi', 'databases');
      final cacheDirFile = Directory(cacheDir);
      if (await cacheDirFile.exists()) {
        try {
          await cacheDirFile.delete(recursive: true);
        } catch (_) {}
      }
    } catch (e) {
      print('Warning: Could not clean database: $e');
    }
  }

  group('CourseScheduleRepository', () {
    late DatabaseHelper dbHelper;
    late CourseScheduleRepository repository;
    late String tableId;
    late String infoId;

    setUp(() async {
      await cleanDatabase();
      await Future.delayed(const Duration(milliseconds: 500));
      dbHelper = DatabaseHelper();

      final db = await dbHelper.database;

      // 创建课程表
      await db.insert('course_tables', {
        'id': 'test-table',
        'name': '2024春季学期',
        'semester_start_date': DateTime(2024, 2, 26).millisecondsSinceEpoch,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      tableId = 'test-table';

      // 创建课程信息
      await db.insert('course_infos', {
        'id': 'test-info',
        'course_table_id': tableId,
        'name': '高等数学',
        'color_value': 0xFF3B82F6,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      infoId = 'test-info';

      repository = CourseScheduleRepositoryImpl(dbHelper);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    final testSchedule = CourseSchedule(
      id: 'test-schedule-1',
      courseInfoId: 'test-info',
      teacher: '张老师',
      location: '教学楼A101',
      dayOfWeek: 1,
      weeks: [1, 2, 3, 4, 5],
      startSection: 1,
      endSection: 2,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('should add schedule successfully', () async {
      await repository.addSchedule(testSchedule);
      final schedules = await repository.getSchedulesByCourseInfoId(infoId);
      expect(schedules.length, equals(1));
      expect(schedules.first.teacher, equals('张老师'));
    });

    test('should get schedules by course info id', () async {
      await repository.addSchedule(testSchedule);
      final schedules = await repository.getSchedulesByCourseInfoId(infoId);
      expect(schedules.length, equals(1));
      expect(schedules.first.location, equals('教学楼A101'));
    });

    test('should update schedule successfully', () async {
      await repository.addSchedule(testSchedule);

      final updated = testSchedule.copyWith(location: '教学楼B202');
      await repository.updateSchedule(updated);

      final schedules = await repository.getSchedulesByCourseInfoId(infoId);
      expect(schedules.first.location, equals('教学楼B202'));
    });

    test('should delete schedule successfully', () async {
      await repository.addSchedule(testSchedule);
      await repository.deleteSchedule('test-schedule-1');

      final schedules = await repository.getSchedulesByCourseInfoId(infoId);
      expect(schedules, isEmpty);
    });
  });

  group('CourseScheduleRepository - Week Queries', () {
    late DatabaseHelper dbHelper;
    late CourseScheduleRepository repository;
    late String tableId;
    late String infoId;

    setUp(() async {
      await cleanDatabase();
      await Future.delayed(const Duration(milliseconds: 500));
      dbHelper = DatabaseHelper();

      final db = await dbHelper.database;

      // 创建课程表
      await db.insert('course_tables', {
        'id': 'test-table',
        'name': '2024春季学期',
        'semester_start_date': DateTime(2024, 2, 26).millisecondsSinceEpoch,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      tableId = 'test-table';

      // 创建课程信息
      await db.insert('course_infos', {
        'id': 'test-info',
        'course_table_id': tableId,
        'name': '高等数学',
        'color_value': 0xFF3B82F6,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      infoId = 'test-info';

      // 添加课程安排：第1-10周
      await db.insert('course_schedules', {
        'id': 'schedule-1',
        'course_info_id': infoId,
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'weeks': '[1,2,3,4,5,6,7,8,9,10]',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 添加课程安排：第8-18周
      await db.insert('course_schedules', {
        'id': 'schedule-2',
        'course_info_id': infoId,
        'teacher': '李老师',
        'location': '教学楼B202',
        'day_of_week': 2,
        'start_section': 3,
        'end_section': 4,
        'weeks': '[8,9,10,11,12,13,14,15,16,17,18]',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      repository = CourseScheduleRepositoryImpl(dbHelper);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should get schedules by week - week 1', () async {
      final schedules = await repository.getSchedulesByWeek(tableId, 1);
      expect(schedules.length, equals(1));
      expect(schedules.first.schedule.dayOfWeek, equals(1));
      expect(schedules.first.info.name, equals('高等数学'));
    });

    test('should get schedules by week - week 8 (overlap)', () async {
      final schedules = await repository.getSchedulesByWeek(tableId, 8);
      expect(schedules.length, equals(2));
    });

    test('should get schedules by week - week 15', () async {
      final schedules = await repository.getSchedulesByWeek(tableId, 15);
      expect(schedules.length, equals(1));
      expect(schedules.first.schedule.dayOfWeek, equals(2));
    });

    test('should return empty when no schedules in week', () async {
      // 添加一个只在第1-2周的课程
      final db = await dbHelper.database;
      await db.insert('course_infos', {
        'id': 'test-info-2',
        'course_table_id': tableId,
        'name': '大学英语',
        'color_value': 0xFF10B981,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('course_schedules', {
        'id': 'schedule-3',
        'course_info_id': 'test-info-2',
        'teacher': '王老师',
        'location': '教学楼C303',
        'day_of_week': 3,
        'start_section': 5,
        'end_section': 6,
        'weeks': '[1,2]',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      final schedules = await repository.getSchedulesByWeek(tableId, 15);
      // 只有 schedule-2 在第15周
      expect(schedules.length, equals(1));
    });
  });

  group('CourseScheduleRepository - CourseViewModel Queries', () {
    late DatabaseHelper dbHelper;
    late CourseScheduleRepository repository;
    late String tableId;

    setUp(() async {
      await cleanDatabase();
      await Future.delayed(const Duration(milliseconds: 500));
      dbHelper = DatabaseHelper();

      final db = await dbHelper.database;

      // 创建课程表
      await db.insert('course_tables', {
        'id': 'test-table',
        'name': '2024春季学期',
        'semester_start_date': DateTime(2024, 2, 26).millisecondsSinceEpoch,
        'total_weeks': 18,
        'time_schedule_id': 'default',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      tableId = 'test-table';

      // 创建课程信息
      await db.insert('course_infos', {
        'id': 'test-info',
        'course_table_id': tableId,
        'name': '高等数学',
        'credit': 4.0,
        'color_value': 0xFF3B82F6,
        'note': '必修课',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 添加课程安排
      await db.insert('course_schedules', {
        'id': 'schedule-1',
        'course_info_id': 'test-info',
        'teacher': '张老师',
        'location': '教学楼A101',
        'day_of_week': 1,
        'start_section': 1,
        'end_section': 2,
        'weeks': '[1,2,3,4,5,6,7,8,9,10]',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      repository = CourseScheduleRepositoryImpl(dbHelper);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should get course view models by week', () async {
      final viewModels = await repository.getCourseViewModelsByWeek(tableId, 1);
      expect(viewModels.length, equals(1));
      expect(viewModels.first.name, equals('高等数学'));
      expect(viewModels.first.teacher, equals('张老师'));
      expect(viewModels.first.location, equals('教学楼A101'));
    });

    test('should get all course view models', () async {
      final viewModels = await repository.getAllCourseViewModels(tableId);
      expect(viewModels.length, equals(1));
      expect(viewModels.first.name, equals('高等数学'));
    });

    test('should return empty list when no course tables', () async {
      final viewModels = await repository.getCourseViewModelsByWeek('non-existent', 1);
      expect(viewModels, isEmpty);
    });
  });
}
