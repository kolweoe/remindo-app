import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/alarm_scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background alarm & notification engine
  try {
    await AlarmScheduler.instance.initialize();
  } catch (_) {}

  runApp(
    const ProviderScope(
      child: RemindoApp(),
    ),
  );
}

class RemindoApp extends StatelessWidget {
  const RemindoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remindo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF8B5CF6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFFFBBF24),
          surface: Color(0xFF1E293B),
          background: Color(0xFF0F172A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
