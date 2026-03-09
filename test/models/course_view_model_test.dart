import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course_info.dart';
import 'package:sleepdown/models/course_schedule.dart';
import 'package:sleepdown/models/course_view_model.dart';

void main() {
  group('CourseViewModel', () {
    late DateTime now;

    setUp(() {
      now = DateTime.now();
    });

    test('should create CourseViewModel from CourseInfo and CourseSchedule', () {
      final info = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        credit: 4.0,
        colorValue: 0xFF3B82F6,
        note: '必修课',
        createdAt: now,
        updatedAt: now,
      );

      final schedule = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final viewModel = CourseViewModel.fromInfoAndSchedule(info, schedule);

      expect(viewModel.id, equals('schedule-id'));
      expect(viewModel.courseInfoId, equals('info-id'));
      expect(viewModel.name, equals('高等数学'));
      expect(viewModel.teacher, equals('张老师'));
      expect(viewModel.location, equals('教学楼A101'));
      expect(viewModel.dayOfWeek, equals(1));
      expect(viewModel.startSection, equals(1));
      expect(viewModel.endSection, equals(2));
      expect(viewModel.colorValue, equals(0xFF3B82F6));
      expect(viewModel.credit, equals(4.0));
      expect(viewModel.note, equals('必修课'));
      expect(viewModel.weeks, equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]));
    });

    test('should return correct useTimeMode', () {
      // 节次模式
      final scheduleSection = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final info = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final viewModelSection = CourseViewModel.fromInfoAndSchedule(info, scheduleSection);
      expect(viewModelSection.useTimeMode, isFalse);

      // 时间模式
      final scheduleTime = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startHour: 14,
        startMinute: 30,
        endHour: 16,
        endMinute: 0,
        createdAt: now,
        updatedAt: now,
      );

      final viewModelTime = CourseViewModel.fromInfoAndSchedule(info, scheduleTime);
      expect(viewModelTime.useTimeMode, isTrue);
    });

    test('should check isActiveInWeek correctly', () {
      final info = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final schedule = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 8, 9, 10],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final viewModel = CourseViewModel.fromInfoAndSchedule(info, schedule);

      expect(viewModel.isActiveInWeek(1), isTrue);
      expect(viewModel.isActiveInWeek(2), isTrue);
      expect(viewModel.isActiveInWeek(5), isFalse);
      expect(viewModel.isActiveInWeek(8), isTrue);
      expect(viewModel.isActiveInWeek(9), isTrue);
      expect(viewModel.isActiveInWeek(10), isTrue);
      expect(viewModel.isActiveInWeek(11), isFalse);
    });

    test('should calculate section count correctly', () {
      final info = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final schedule = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 3,
        endSection: 5,
        createdAt: now,
        updatedAt: now,
      );

      final viewModel = CourseViewModel.fromInfoAndSchedule(info, schedule);

      expect(viewModel.sectionCount, equals(3));
    });

    test('should return correct time display text for section mode', () {
      final info = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final schedule = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 3,
        endSection: 4,
        createdAt: now,
        updatedAt: now,
      );

      final viewModel = CourseViewModel.fromInfoAndSchedule(info, schedule);

      expect(viewModel.timeDisplayText, equals('第3-4节'));
    });

    test('should return correct time display text for time mode', () {
      final info = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final schedule = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startHour: 14,
        startMinute: 30,
        endHour: 16,
        endMinute: 0,
        createdAt: now,
        updatedAt: now,
      );

      final viewModel = CourseViewModel.fromInfoAndSchedule(info, schedule);

      expect(viewModel.timeDisplayText, equals('14:30-16:00'));
    });

    test('should create copy with modified fields', () {
      final info = CourseInfo(
        id: 'info-id',
        courseTableId: 'table-id',
        name: '高等数学',
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final schedule = CourseSchedule(
        id: 'schedule-id',
        courseInfoId: 'info-id',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        weeks: [1, 2, 3],
        startSection: 1,
        endSection: 2,
        createdAt: now,
        updatedAt: now,
      );

      final viewModel = CourseViewModel.fromInfoAndSchedule(info, schedule);

      final updated = viewModel.copyWith(
        location: '教学楼B202',
        dayOfWeek: 2,
      );

      expect(updated.location, equals('教学楼B202'));
      expect(updated.dayOfWeek, equals(2));
      expect(updated.id, equals(viewModel.id));
      expect(updated.name, equals(viewModel.name));
    });

    test('should compare equality by id', () {
      final viewModel1 = CourseViewModel(
        id: 'viewmodel-id',
        courseInfoId: 'info-id',
        name: '高等数学',
        teacher: '张老师',
        location: '教学楼A101',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weeks: [1, 2, 3],
        colorValue: 0xFF3B82F6,
        createdAt: now,
        updatedAt: now,
      );

      final viewModel2 = CourseViewModel(
        id: 'viewmodel-id',
        courseInfoId: 'other-info',
        name: '线性代数',
        teacher: '李老师',
        location: '其他地点',
        dayOfWeek: 2,
        startSection: 3,
        endSection: 4,
        weeks: [4, 5],
        colorValue: 0xFF000000,
        createdAt: now,
        updatedAt: now,
      );

      expect(viewModel1, equals(viewModel2));
    });
  });
}
