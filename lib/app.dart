import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/backup_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/common/forgot_pin_screen.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';
import 'providers/teacher/attendance_provider.dart';
import 'providers/teacher/holiday_provider.dart';
import 'providers/teacher/month_provider.dart';
import 'providers/teacher/weekday_provider.dart';
import './routes/teacher_routes.dart';
import 'providers/teacher/course_provider.dart';
import 'routes/navigator.dart';
import 'screens/common/about_screen.dart';
import 'services/backup_service.dart';
import 'services/teacher/attendance_service.dart';
import 'services/teacher/course_service.dart';
import 'services/teacher/holiday_service.dart';
import 'services/teacher/weekday_service.dart';
import 'constants/app_theme.dart';
import 'providers/teacher/payment_provider.dart';
import 'providers/teacher/student_provider.dart';
import 'services/teacher/payment_service.dart';
import 'services/teacher/student_service.dart';

class MyApp extends StatelessWidget {
  final materialTheme = const MaterialTheme();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentProvider(StudentService()),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(PaymentService()),
        ),
        ChangeNotifierProvider(
          create: (context) => MonthlyProvider(PaymentService()),
        ),
        ChangeNotifierProvider(
            create: (context) => AttendanceProvider(AttendanceService())),
        ChangeNotifierProvider(
            create: (context) => HolidayProvider(HolidayService())),
        ChangeNotifierProvider(
            create: (context) => WeekdayProvider(WeekdayService())),
        ChangeNotifierProvider(
            create: (context) => CourseProvider(CourseService())),
        ChangeNotifierProvider(create: (context) {
          final themeProvider = ThemeProvider();
          themeProvider.loadThemePreference();
          return themeProvider;
        }),
        ChangeNotifierProvider(
          create: (_) => BackupProvider(BackupService()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            navigatorObservers: [RouteObserver()],
            title: Config().appName,
            themeMode: themeProvider.themeMode,
            theme: materialTheme.light(),
            darkTheme: materialTheme.dark(),
            initialRoute: '/login',
            routes: {
              ...teacherRoutes,
              '/about': (context) => const AboutScreen(),
              '/forgot-pin': (context) => const ForgotPinScreen(),
            },
          );
        },
      ),
    );
  }
}
