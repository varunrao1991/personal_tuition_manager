import 'package:flutter/material.dart';
import 'package:yoglogonline/screens/common/notification_screen.dart';
import 'package:yoglogonline/services/firebase_service.dart';
import 'providers/student/attendance_provider.dart';
import 'providers/student/holiday_provider.dart';
import 'providers/student/weekday_provider.dart';
import './routes/student_routes.dart';
import 'providers/student/course_provider.dart';
import 'routes/navigator.dart';
import 'screens/common/about_screen.dart';
import 'screens/common/forgot_password_screen.dart';
import 'services/student/attendance_service.dart';
import 'services/student/course_service.dart';
import 'services/student/holiday_service.dart';
import 'services/student/weekday_service.dart';
import 'constants/app_theme.dart';
import 'providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/common/change_password_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/token_service.dart';
import 'utils/http_client.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    MaterialTheme theme = const MaterialTheme();

    return MultiProvider(
      providers: [
        Provider(create: (_) => HttpTimeoutClient()),
        Provider(create: (_) => TokenService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
              AuthService(context.read<HttpTimeoutClient>()),
              FirebaseService(),
              context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
            create: (context) => AttendanceProvider(
                AttendanceService(context.read<HttpTimeoutClient>()),
                context.read<TokenService>())),
        ChangeNotifierProvider(
            create: (context) => HolidayProvider(
                HolidayService(context.read<HttpTimeoutClient>()),
                context.read<TokenService>())),
        ChangeNotifierProvider(
            create: (context) => WeekdayProvider(
                WeekdayService(context.read<HttpTimeoutClient>()),
                context.read<TokenService>())),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
              NotificationService(context.read<HttpTimeoutClient>()),
              context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
            create: (context) => CourseProvider(
                CourseService(context.read<HttpTimeoutClient>()),
                context.read<TokenService>())),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [RouteObserver()],
        title: 'Student App',
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        initialRoute: '/login',
        routes: {
          ...studentRoutes,
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/about': (context) => const AboutScreen(),
          '/notification': (context) => const NotificationScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
        },
      ),
    );
  }
}
