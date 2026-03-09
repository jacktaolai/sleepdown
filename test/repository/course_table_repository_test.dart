import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sleepdown/database/db_helper.dart';
import 'package:sleepdown/models/models.dart';
import 'package:sleepdown/repository/repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;
  late CourseTableRepository repository;

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.execute('PRAGMA foreign_keys = ON');
    await db.delete('course_tables');
    repository = CourseTableRepository(dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('CourseTableRepository', () {
    test('addCourseTable adds new table', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final table = CourseTable(
        id: 'test_$now',
        name: '测试课程表',
        semesterStartDate: DateTime(2026, 2, 23),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addCourseTable(table);
      final result = await repository.getCourseTableById('test_$now');
      
      expect(result, isNotNull);
      expect(result!.name, '测试课程表');
      
      await repository.deleteCourseTable('test_$now');
    });

    test('getAllCourseTables returns all tables', () async {
      final tables = await repository.getAllCourseTables();
      
      expect(tables, isA<List<CourseTable>>());
    });

    test('updateCourseTable updates existing table', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final table = CourseTable(
        id: 'update_$now',
        name: '原始名称',
        semesterStartDate: DateTime(2026, 2, 23),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addCourseTable(table);
      
      final updated = table.copyWith(name: '新名称', totalWeeks: 20);
      await repository.updateCourseTable(updated);
      
      final result = await repository.getCourseTableById('update_$now');
      expect(result!.name, '新名称');
      expect(result.totalWeeks, 20);
      
      await repository.deleteCourseTable('update_$now');
    });

    test('deleteCourseTable removes table', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final table = CourseTable(
        id: 'delete_$now',
        name: '待删除',
        semesterStartDate: DateTime(2026, 2, 23),
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addCourseTable(table);
      await repository.deleteCourseTable('delete_$now');
      
      final result = await repository.getCourseTableById('delete_$now');
      expect(result, isNull);
    });

    test('getCourseTableById returns null for non-existent', () async {
      final result = await repository.getCourseTableById('non_existent');
      
      expect(result, isNull);
    });
  });
}
