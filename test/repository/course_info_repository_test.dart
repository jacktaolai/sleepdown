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
  late CourseInfoRepository repository;

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.execute('PRAGMA foreign_keys = ON');
    await db.delete('course_tables');
    await db.delete('course_infos');
    
    tableRepo = CourseTableRepository(dbHelper);
    repository = CourseInfoRepository(dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('CourseInfoRepository', () {
    late String tableId;

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
    });

    test('addCourseInfo adds new course info', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final info = CourseInfo(
        id: 'info_$now',
        courseTableId: tableId,
        name: '数据结构',
        credit: 3.0,
        colorValue: 0xFF3B82F6,
        note: '重要课程',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addCourseInfo(info);
      final result = await repository.getCourseInfoById('info_$now');
      
      expect(result, isNotNull);
      expect(result!.name, '数据结构');
      expect(result.credit, 3.0);
      
      await repository.deleteCourseInfo('info_$now');
    });

    test('getCourseInfosByTableId returns all course infos', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final info1 = CourseInfo(
        id: 'info1_$now',
        courseTableId: tableId,
        name: '课程1',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final info2 = CourseInfo(
        id: 'info2_$now',
        courseTableId: tableId,
        name: '课程2',
        colorValue: 0xFF10B981,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addCourseInfo(info1);
      await repository.addCourseInfo(info2);

      final results = await repository.getCourseInfosByTableId(tableId);
      expect(results.length, 2);
      
      await repository.deleteCourseInfo('info1_$now');
      await repository.deleteCourseInfo('info2_$now');
    });

    test('deleteCourseInfo removes course info', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final info = CourseInfo(
        id: 'delete_$now',
        courseTableId: tableId,
        name: '待删除',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addCourseInfo(info);
      await repository.deleteCourseInfo('delete_$now');
      
      final result = await repository.getCourseInfoById('delete_$now');
      expect(result, isNull);
    });

    test('getCourseInfoById returns null for non-existent', () async {
      final result = await repository.getCourseInfoById('non_existent');
      expect(result, isNull);
    });

    test('course info with null credit works correctly', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final info = CourseInfo(
        id: 'no_credit_$now',
        courseTableId: tableId,
        name: '无学分课程',
        colorValue: 0xFF3B82F6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addCourseInfo(info);
      final result = await repository.getCourseInfoById('no_credit_$now');
      
      expect(result, isNotNull);
      expect(result!.credit, isNull);
      
      await repository.deleteCourseInfo('no_credit_$now');
    });
  });
}
