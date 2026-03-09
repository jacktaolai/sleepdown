import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/models.dart';

void main() {
  group('CourseInfo', () {
    final now = DateTime.now();

    test('toMap and fromMap work correctly', () {
      final info = CourseInfo(
        id: 'test_id',
        courseTableId: 'table_id',
        name: '数据结构',
        credit: 3.0,
        colorValue: 0xFF3B82F6,
        note: '重要课程',
        createdAt: now,
        updatedAt: now,
      );
      
      final map = info.toMap();
      final restored = CourseInfo.fromMap(map);
      
      expect(restored.id, info.id);
      expect(restored.courseTableId, info.courseTableId);
      expect(restored.name, info.name);
      expect(restored.credit, info.credit);
      expect(restored.colorValue, info.colorValue);
      expect(restored.note, info.note);
    });

    test('fromMap handles null credit', () {
      final map = {
        'id': 'test_id',
        'course_table_id': 'table_id',
        'name': '数据结构',
        'credit': null,
        'color_value': 0xFF3B82F6,
        'note': null,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };
      
      final info = CourseInfo.fromMap(map);
      
      expect(info.credit, isNull);
      expect(info.note, isNull);
    });

    test('copyWith works correctly', () {
      final info = CourseInfo(
        id: 'test_id',
        courseTableId: 'table_id',
        name: '原始名称',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );
      
      final updated = info.copyWith(name: '新名称', credit: 4.0);
      
      expect(updated.id, 'test_id');
      expect(updated.name, '新名称');
      expect(updated.credit, 4.0);
      expect(updated.colorValue, 0xFF3B82F6);
    });
  });
}
