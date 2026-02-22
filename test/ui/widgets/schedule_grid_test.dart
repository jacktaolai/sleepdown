import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleepdown/models/course.dart';
import 'package:sleepdown/ui/widgets/schedule_grid.dart';

void main() {
  group('ScheduleGrid', () {
    testWidgets('should display time column', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScheduleGrid(
                courses: [],
                currentWeek: 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('should display courses', (tester) async {
      final courses = [
        Course(
          id: '1',
          name: 'Math',
          dayOfWeek: 1,
          startSection: 1,
          endSection: 2,
          weekRanges: const [WeekRange(start: 1, end: 16)],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScheduleGrid(
                courses: courses,
                currentWeek: 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Math'), findsOneWidget);
    });

    testWidgets('should handle course tap', (tester) async {
      final courses = [
        Course(
          id: '1',
          name: 'Math',
          dayOfWeek: 1,
          startSection: 1,
          endSection: 2,
          weekRanges: const [WeekRange(start: 1, end: 16)],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            routes: {
              '/course/1': (context) => const Scaffold(body: Text('Detail')),
            },
            home: Scaffold(
              body: ScheduleGrid(
                courses: courses,
                currentWeek: 1,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Math'));
      await tester.pumpAndSettle();

      expect(find.text('Detail'), findsOneWidget);
    });
  });
}
