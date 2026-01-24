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
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:mobile/data/models/sync_queue_model.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/preferences_provider.dart';
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
  Hive.registerAdapter(MaterialRequestModelAdapter());
  Hive.registerAdapter(MaterialRequestItemModelAdapter());
  Hive.registerAdapter(ProjectModelAdapter());
  Hive.registerAdapter(SyncQueueModelAdapter());
  
  // Open Boxes
  await Hive.openBox<AttendanceModel>(AppConstants.attendanceBox);
  await Hive.openBox<TaskModel>(AppConstants.taskBox);
  await Hive.openBox<DprModel>(AppConstants.dprBox);
  await Hive.openBox<MaterialRequestModel>(AppConstants.materialRequestBox);
  await Hive.openBox<ProjectModel>(AppConstants.projectBox);
  await Hive.openBox<SyncQueueModel>(AppConstants.syncQueueBox);
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final languageCode = ref.watch(languageProvider);

    Locale resolveLocale(String code) {
      switch (code) {
        case 'hi':
          return const Locale('hi', 'IN');
        case 'ta':
          return const Locale('ta', 'IN');
        case 'mr':
          return const Locale('mr', 'IN');
        default:
          return const Locale('en', 'US');
      }
    }
    
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
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
      locale: resolveLocale(languageCode),
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
