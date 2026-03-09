import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/models.dart';

void main() {
  group('CourseTable', () {
    final now = DateTime.now();
    final semesterStart = DateTime(2026, 2, 23);

    test('toMap and fromMap work correctly', () {
      final table = CourseTable(
        id: 'test_id',
        name: '测试课程表',
        semesterStartDate: semesterStart,
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );
      
      final map = table.toMap();
      final restored = CourseTable.fromMap(map);
      
      expect(restored.id, table.id);
      expect(restored.name, table.name);
      expect(restored.semesterStartDate.millisecondsSinceEpoch, semesterStart.millisecondsSinceEpoch);
      expect(restored.totalWeeks, table.totalWeeks);
      expect(restored.timeScheduleId, table.timeScheduleId);
    });

    test('fromMap uses default totalWeeks when null', () {
      final map = {
        'id': 'test_id',
        'name': '测试',
        'semester_start_date': semesterStart.millisecondsSinceEpoch,
        'time_schedule_id': 'default',
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };
      
      final table = CourseTable.fromMap(map);
      
      expect(table.totalWeeks, 18);
    });

    test('copyWith works correctly', () {
      final table = CourseTable(
        id: 'test_id',
        name: '原始名称',
        semesterStartDate: semesterStart,
        totalWeeks: 18,
        timeScheduleId: 'default',
        createdAt: now,
        updatedAt: now,
      );
      
      final updated = table.copyWith(name: '新名称', totalWeeks: 20);
      
      expect(updated.id, 'test_id');
      expect(updated.name, '新名称');
      expect(updated.totalWeeks, 20);
      expect(updated.timeScheduleId, 'default');
    });
  });
}
