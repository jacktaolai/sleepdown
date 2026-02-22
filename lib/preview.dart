import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/app_settings.dart';
import 'models/course.dart';
import 'models/time_schedule.dart';
import 'repository/settings_repository.dart';
import 'repository/course_repository.dart';
import 'providers/providers.dart';
import 'theme/app_theme.dart';
import 'ui/widgets/course_card.dart';
import 'ui/widgets/schedule_grid.dart';
import 'ui/widgets/week_calendar_strip.dart';
import 'ui/widgets/week_schedule_view.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/add_course_screen.dart';

/// 用于预览的 Mock CourseRepository
class MockCourseRepository implements CourseRepository {
  final List<Course> _courses;

  MockCourseRepository({List<Course>? courses}) : _courses = courses ?? [];

  @override
  Future<List<Course>> getAllCourses() async => _courses;

  @override
  Future<List<Course>> getCoursesByWeek(int week) async {
    return _courses.where((course) => course.isActiveInWeek(week)).toList();
  }

  @override
  Future<List<Course>> getCoursesByDay(int dayOfWeek) async {
    return _courses.where((course) => course.dayOfWeek == dayOfWeek).toList();
  }

  @override
  Future<Course?> getCourseById(String id) async {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addCourse(Course course) async {}

  @override
  Future<void> updateCourse(Course course) async {}

  @override
  Future<void> deleteCourse(String id) async {}

  @override
  Future<void> close() async {}
}

/// 用于预览的 Mock SettingsRepository
class MockSettingsRepository implements SettingsRepository {
  final AppSettings _settings;

  MockSettingsRepository({AppSettings? settings})
      : _settings = settings ?? const AppSettings();

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> updateSettings(AppSettings settings) async {}

  @override
  Future<TimeSchedule?> getTimeSchedule() async => null;

  @override
  Future<TimeSchedule?> getTimeScheduleById(String id) async => null;

  @override
  Future<List<TimeSchedule>> getAllTimeSchedules() async => [];

  @override
  Future<void> updateTimeSchedule(TimeSchedule schedule) async {}

  @override
  Future<void> addTimeSchedule(TimeSchedule schedule) async {}

  @override
  Future<void> deleteTimeSchedule(String id) async {}

  @override
  Future<void> setDefaultTimeSchedule(String id) async {}

  @override
  Future<void> close() async {}
}

/// 预览入口 - 使用方法: flutter run -t lib/preview.dart
void main() {
  runApp(const WidgetPreviewApp());
}

class WidgetPreviewApp extends StatelessWidget {
  const WidgetPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Preview',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const PreviewHomePage(),
    );
  }
}

class PreviewHomePage extends StatelessWidget {
  const PreviewHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('组件预览'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // WeekCalendarStrip 预览
          _buildSectionTitle('WeekCalendarStrip'),
          _buildPreviewCard(
            context,
            '当前周 (第1周)',
            ProviderScope(
              overrides: [
                settingsRepositoryProvider.overrideWithValue(
                  MockSettingsRepository(
                    settings: AppSettings(
                      semesterStartDate: DateTime(2026, 2, 16),
                      totalWeeks: 20,
                    ),
                  ),
                ),
              ],
              child: const WeekCalendarStrip(),
            ),
          ),
          const SizedBox(height: 32),

          // CourseCard 预览
          _buildSectionTitle('CourseCard'),
          _buildPreviewCard(
            context,
            '当前周课程',
            SizedBox(
              width: 100,
              height: 80,
              child: CourseCard(
                course: Course(
                  id: '1',
                  name: '数据结构',
                  teacher: '张三',
                  location: 'A301',
                  dayOfWeek: 1,
                  startSection: 1,
                  endSection: 2,
                  weekRanges: [WeekRange(start: 1, end: 16)],
                  colorValue: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                isCurrentWeek: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewCard(
            context,
            '非本周课程',
            SizedBox(
              width: 100,
              height: 80,
              child: CourseCard(
                course: Course(
                  id: '2',
                  name: '算法设计',
                  teacher: '李四',
                  location: 'B205',
                  dayOfWeek: 3,
                  startSection: 3,
                  endSection: 4,
                  weekRanges: [WeekRange(start: 1, end: 16)],
                  colorValue: 1,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                isCurrentWeek: false,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewCard(
            context,
            '多颜色变体',
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(5, (index) {
                  return SizedBox(
                    width: 100,
                    height: 80,
                    child: CourseCard(
                      course: Course(
                        id: '$index',
                        name: '课程$index',
                        teacher: '教师$index',
                        location: '教室$index',
                        dayOfWeek: 1,
                        startSection: 1,
                        endSection: 2,
                        weekRanges: [WeekRange(start: 1, end: 16)],
                        colorValue: index,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                      isCurrentWeek: true,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // WeekScheduleView 预览 (合并组件)
          _buildSectionTitle('WeekScheduleView (合并组件)'),
          _buildPreviewCard(
            context,
            '有课程',
            SizedBox(
              width: 360,
              height: 500,
              child: WeekScheduleView(
                courses: [
                  Course(
                    id: '1',
                    name: '数据结构',
                    teacher: '张三',
                    location: 'A301',
                    dayOfWeek: 1,
                    startSection: 1,
                    endSection: 2,
                    weekRanges: [WeekRange(start: 1, end: 16)],
                    colorValue: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  Course(
                    id: '2',
                    name: '算法设计',
                    teacher: '李四',
                    location: 'B205',
                    dayOfWeek: 2,
                    startSection: 3,
                    endSection: 4,
                    weekRanges: [WeekRange(start: 1, end: 16)],
                    colorValue: 1,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  Course(
                    id: '3',
                    name: '操作系统',
                    teacher: '王五',
                    location: 'C402',
                    dayOfWeek: 3,
                    startSection: 5,
                    endSection: 6,
                    weekRanges: [WeekRange(start: 1, end: 16)],
                    colorValue: 2,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  Course(
                    id: '4',
                    name: '计算机网络',
                    teacher: '赵六',
                    location: 'D101',
                    dayOfWeek: 5,
                    startSection: 7,
                    endSection: 8,
                    weekRanges: [WeekRange(start: 1, end: 16)],
                    colorValue: 3,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ],
                currentWeek: 1,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ScheduleGrid 预览
          _buildSectionTitle('ScheduleGrid'),
          _buildPreviewCard(
            context,
            '空课程表',
            const SizedBox(
              width: 360,
              height: 400,
              child: ScheduleGrid(
                courses: [],
                currentWeek: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildPreviewCard(
            context,
            '有课程',
            SizedBox(
              width: 360,
              height: 400,
              child: ScheduleGrid(
                courses: [
                  Course(
                    id: '1',
                    name: '数据结构',
                    teacher: '张三',
                    location: 'A301',
                    dayOfWeek: 1,
                    startSection: 1,
                    endSection: 2,
                    weekRanges: [WeekRange(start: 1, end: 16)],
                    colorValue: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  Course(
                    id: '2',
                    name: '算法设计',
                    teacher: '李四',
                    location: 'B205',
                    dayOfWeek: 2,
                    startSection: 3,
                    endSection: 4,
                    weekRanges: [WeekRange(start: 1, end: 16)],
                    colorValue: 1,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  Course(
                    id: '3',
                    name: '操作系统',
                    teacher: '王五',
                    location: 'C402',
                    dayOfWeek: 3,
                    startSection: 5,
                    endSection: 6,
                    weekRanges: [WeekRange(start: 1, end: 16)],
                    colorValue: 2,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  Course(
                    id: '4',
                    name: '计算机网络',
                    teacher: '赵六',
                    location: 'D101',
                    dayOfWeek: 5,
                    startSection: 7,
                    endSection: 8,
                    weekRanges: [WeekRange(start: 1, end: 16)],
                    colorValue: 3,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ],
                currentWeek: 1,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // AddCourseScreen 预览
          _buildSectionTitle('AddCourseScreen (添加课程)'),
          _buildPreviewCard(
            context,
            '添加课程页面',
            const SizedBox(
              width: 360,
              height: 700,
              child: AddCourseScreen(),
            ),
          ),
          const SizedBox(height: 32),

          // HomeScreen 预览
          _buildSectionTitle('HomeScreen (周课表)'),
          _buildPreviewCard(
            context,
            '完整周课表页面',
            ProviderScope(
              overrides: [
                settingsRepositoryProvider.overrideWithValue(
                  MockSettingsRepository(
                    settings: AppSettings(
                      semesterStartDate: DateTime(2026, 2, 16),
                      totalWeeks: 20,
                    ),
                  ),
                ),
                courseRepositoryProvider.overrideWithValue(
                  MockCourseRepository(
                    courses: [
                      Course(
                        id: '1',
                        name: '数据结构',
                        teacher: '张三',
                        location: 'A301',
                        dayOfWeek: 1,
                        startSection: 1,
                        endSection: 2,
                        weekRanges: [WeekRange(start: 1, end: 16)],
                        colorValue: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                      Course(
                        id: '2',
                        name: '算法设计',
                        teacher: '李四',
                        location: 'B205',
                        dayOfWeek: 2,
                        startSection: 3,
                        endSection: 4,
                        weekRanges: [WeekRange(start: 1, end: 16)],
                        colorValue: 1,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    ],
                  ),
                ),
              ],
              child: const HomeScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, String title, Widget preview) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: preview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
