import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course.dart';
import 'package:sleepdown/ui/widgets/course_card.dart';

void main() {
  group('CourseCard', () {
    testWidgets('should display course information correctly', (tester) async {
      final course = Course(
        id: '1',
        name: 'Math',
        teacher: 'Prof. Wang',
        location: 'Room 101',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        colorValue: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(course: course),
          ),
        ),
      );

      expect(find.text('Math'), findsOneWidget);
      expect(find.text('@Room 101'), findsOneWidget);
      expect(find.text('Prof. Wang'), findsOneWidget);
    });

    testWidgets('should display "Not Current Week" label when isCurrentWeek is false', (tester) async {
      final course = Course(
        id: '1',
        name: 'Math',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: course,
              isCurrentWeek: false,
            ),
          ),
        ),
      );

      expect(find.text('[非本周]'), findsOneWidget);
    });

    testWidgets('should trigger onTap callback', (tester) async {
      bool tapped = false;
      final course = Course(
        id: '1',
        name: 'Math',
        dayOfWeek: 1,
        startSection: 1,
        endSection: 2,
        weekRanges: const [WeekRange(start: 1, end: 16)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              course: course,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CourseCard));
      expect(tapped, isTrue);
    });
  });
}
