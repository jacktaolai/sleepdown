import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleepdown/models/app_settings.dart';
import 'package:sleepdown/models/course.dart';
import 'package:sleepdown/providers/providers.dart';
import 'package:sleepdown/ui/screens/home_screen.dart';
import 'package:sleepdown/repository/settings_repository.dart';
import 'package:sleepdown/repository/course_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockCourseRepository extends Mock implements CourseRepository {}

class SettingsNotifierMock extends SettingsNotifier {
  SettingsNotifierMock(AppSettings settings) : super(_createMockRepo()) {
    state = settings;
  }

  static SettingsRepository _createMockRepo() {
    final repo = MockSettingsRepository();
    when(() => repo.getSettings()).thenAnswer((_) async => const AppSettings());
    when(() => repo.close()).thenAnswer((_) async {});
    return repo;
  }
}

class CourseNotifierMock extends CourseNotifier {
  CourseNotifierMock(List<Course> courses) : super(_createMockRepo()) {
    state = courses;
  }

  static CourseRepository _createMockRepo() {
    final repo = MockCourseRepository();
    when(() => repo.getAllCourses()).thenAnswer((_) async => []);
    when(() => repo.close()).thenAnswer((_) async {});
    return repo;
  }
}

void main() {
  group('HomeScreen', () {
    testWidgets('should display header with current week', (tester) async {
      final semesterStart = DateTime(2026, 2, 17);
      final settings = AppSettings(
        semesterStartDate: semesterStart,
        totalWeeks: 18,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) => SettingsNotifierMock(settings)),
            currentWeekProvider.overrideWith((ref) => 1),
            courseListProvider.overrideWith((ref) => CourseNotifierMock([])),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('第1周'), findsOneWidget);
      expect(find.text('· 进行中'), findsOneWidget);
    });

    testWidgets('should display courses in grid', (tester) async {
      final semesterStart = DateTime(2026, 2, 17);
      final settings = AppSettings(
        semesterStartDate: semesterStart,
        totalWeeks: 18,
      );

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
          overrides: [
            settingsProvider.overrideWith((ref) => SettingsNotifierMock(settings)),
            currentWeekProvider.overrideWith((ref) => 1),
            courseListProvider.overrideWith((ref) => CourseNotifierMock(courses)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Math'), findsOneWidget);
    });
  });
}
