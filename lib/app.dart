import 'package:flutter/material.dart';
import 'package:padmayoga/providers/attendance_provider.dart';
import 'package:padmayoga/providers/holiday_provider.dart';
import 'package:padmayoga/providers/month_provider.dart';
import 'package:padmayoga/providers/weekday_provider.dart';
import 'package:padmayoga/routes/teacher_routes.dart';
import 'package:padmayoga/screens/about_screen.dart';
import 'package:padmayoga/services/attendance_service.dart';
import 'package:padmayoga/services/course_service.dart';
import 'package:padmayoga/services/holiday_service.dart';
import 'package:padmayoga/services/weekday_service.dart';
import 'package:padmayoga/utils/http_client.dart';
import 'providers/course_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/student_provider.dart';
import 'routes/auth_routes.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/change_password_screen.dart';
import 'services/auth_service.dart';
import 'services/payment_service.dart';
import 'services/student_service.dart';
import 'services/token_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            create: (context) => CourseProvider(
                CourseService(context.read<HttpTimeoutClient>()),
                context.read<TokenService>()))
      ],
      child: MaterialApp(
        navigatorObservers: [RouteObserver()],
        title: 'Teacher & Student App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          ...authRoutes,
          ...teacherRoutes,
          '/about': (context) => const AboutScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
        },
      ),
    );
  }
}
