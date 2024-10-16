import 'package:flutter/material.dart';
import 'package:yoglogonline/screens/common/notification_screen.dart';
import './providers/attendance_provider.dart';
import './providers/holiday_provider.dart';
import './providers/month_provider.dart';
import './providers/weekday_provider.dart';
import './routes/teacher_routes.dart';
import 'routes/navigator.dart';
import 'screens/common/about_screen.dart';
import './services/attendance_service.dart';
import './services/course_service.dart';
import './services/holiday_service.dart';
import './services/weekday_service.dart';
import 'constants/app_theme.dart';
import 'providers/course_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/student_provider.dart';
import 'routes/auth_routes.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/common/change_password_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'services/student_service.dart';
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
              context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentProvider(
              StudentService(context.read<HttpTimeoutClient>()),
              context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(
              PaymentService(context.read<HttpTimeoutClient>()),
              context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => MonthlyProvider(
              PaymentService(context.read<HttpTimeoutClient>()),
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
        title: 'Teacher & Student App',
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        initialRoute: '/login',
        routes: {
          ...authRoutes,
          ...teacherRoutes,
          '/about': (context) => const AboutScreen(),
          '/notification': (context) => const NotificationScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
        },
      ),
    );
  }
}
