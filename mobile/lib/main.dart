import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/data/models/attendance_model.dart';
import 'package:mobile/data/models/task_model.dart';
import 'package:mobile/data/models/dpr_model.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/presentation/screens/auth/login_screen.dart';
import 'package:mobile/presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(DprModelAdapter());
  
  // Open Boxes
  await Hive.openBox<AttendanceModel>(AppConstants.attendanceBox);
  await Hive.openBox<TaskModel>(AppConstants.taskBox);
  await Hive.openBox<DprModel>(AppConstants.dprBox);
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return MaterialApp(
      title: 'Construction Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en', 'US'),
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => const LoginScreen(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
