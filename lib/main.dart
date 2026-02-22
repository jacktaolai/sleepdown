import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/db_helper.dart';
import 'providers/providers.dart';
import 'repository/course_repository.dart';
import 'repository/settings_repository.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbHelper = DatabaseHelper();
  final courseRepository = CourseRepositoryImpl(dbHelper);
  final settingsRepository = SettingsRepositoryImpl(dbHelper);

  runApp(
    ProviderScope(
      overrides: [
        courseRepositoryProvider.overrideWithValue(courseRepository),
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleepdown',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      routes: {
        '/course/edit': (context) => const Scaffold(body: Center(child: Text('Edit Course Screen Placeholder'))),
        // Add other routes here
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/course/') ?? false) {
          final courseId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => Scaffold(body: Center(child: Text('Course Detail: $courseId'))),
          );
        }
        return null;
      },
    );
  }
}
