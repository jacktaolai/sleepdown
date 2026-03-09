import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course_info.dart';

void main() {
  group('CourseInfo', () {
    test('should create CourseInfo with required fields', () {
      final now = DateTime.now();
      final info = CourseInfo(
        id: 'test-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      expect(info.id, equals('test-id'));
      expect(info.courseTableId, equals('table-id'));
      expect(info.name, equals('高等数学'));
      expect(info.colorValue, equals(0xFF3B82F6));
    });

    test('should create CourseInfo with optional fields', () {
      final now = DateTime.now();
      final info = CourseInfo(
        id: 'test-id',
        courseTableId: 'table-id',
        name: '高等数学',
        credit: 4.0,
        colorValue: 0xFF3B82F6,
        note: '必修课',
        createdAt: now,
        updatedAt: now,
      );

      expect(info.credit, equals(4.0));
      expect(info.note, equals('必修课'));
    });

    test('should convert to map correctly', () {
      final now = DateTime(2026, 1, 1, 0, 0, 0);
      final info = CourseInfo(
        id: 'test-id',
        courseTableId: 'table-id',
        name: '高等数学',
        credit: 4.0,
        colorValue: 0xFF3B82F6,
        note: '必修课',
        createdAt: now,
        updatedAt: now,
      );

      final map = info.toMap();

      expect(map['id'], equals('test-id'));
      expect(map['course_table_id'], equals('table-id'));
      expect(map['name'], equals('高等数学'));
      expect(map['credit'], equals(4.0));
      expect(map['color_value'], equals(0xFF3B82F6));
      expect(map['note'], equals('必修课'));
    });

    test('should create from map correctly', () {
      final map = {
        'id': 'test-id',
        'course_table_id': 'table-id',
        'name': '高等数学',
        'credit': 4.0,
        'color_value': 0xFF3B82F6,
        'note': '必修课',
        'created_at': 1704067200000,
        'updated_at': 1704067200000,
      };

      final info = CourseInfo.fromMap(map);

      expect(info.id, equals('test-id'));
      expect(info.courseTableId, equals('table-id'));
      expect(info.name, equals('高等数学'));
      expect(info.credit, equals(4.0));
      expect(info.colorValue, equals(0xFF3B82F6));
      expect(info.note, equals('必修课'));
    });

    test('should handle null credit in map', () {
      final map = {
        'id': 'test-id',
        'course_table_id': 'table-id',
        'name': '高等数学',
        'credit': null,
        'color_value': 0xFF3B82F6,
        'note': null,
        'created_at': 1704067200000,
        'updated_at': 1704067200000,
      };

      final info = CourseInfo.fromMap(map);

      expect(info.credit, isNull);
      expect(info.note, isNull);
    });

    test('should create copy with modified fields', () {
      final now = DateTime.now();
      final info = CourseInfo(
        id: 'test-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final updated = info.copyWith(name: '线性代数', credit: 3.0);

      expect(updated.name, equals('线性代数'));
      expect(updated.credit, equals(3.0));
      expect(updated.id, equals(info.id));
    });

    test('should compare equality by id', () {
      final now = DateTime.now();
      final info1 = CourseInfo(
        id: 'test-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final info2 = CourseInfo(
        id: 'test-id',
        courseTableId: 'other-table',
        name: '不同的课程',
        colorValue: 0xFF000000,
        createdAt: now,
        updatedAt: now,
      );

      expect(info1, equals(info2));
    });
  });
}
