import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/db_helper.dart';
import 'providers/providers.dart';
import 'theme/app_theme.dart';
import 'ui/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbHelper = DatabaseHelper();

  runApp(
    ProviderScope(
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
      home: const MainScreen(),
      routes: {
        '/course/edit': (context) => const Scaffold(body: Center(child: Text('Edit Course Screen Placeholder'))),
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
