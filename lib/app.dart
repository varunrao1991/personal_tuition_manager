import 'package:flutter/material.dart';
import 'package:padmayoga/providers/attendance_provider.dart';
import 'package:padmayoga/providers/holiday_provider.dart';
import 'package:padmayoga/providers/month_provider.dart';
import 'package:padmayoga/providers/weekday_provider.dart';
import 'package:padmayoga/screens/about_screen.dart';
import 'package:padmayoga/screens/teacher/holiday_screen.dart';
import 'package:padmayoga/services/attendance_service.dart';
import 'package:padmayoga/services/holiday_service.dart';
import 'package:padmayoga/services/weekday_service.dart';
import 'providers/payment_provider.dart';
import 'providers/student_provider.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import './screens/auth/login_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';
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
        Provider(
            create: (_) => TokenService()), // Provide TokenService globally
        ChangeNotifierProvider(
          create: (context) =>
              AuthProvider(AuthService(), context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              StudentProvider(StudentService(), context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              PaymentProvider(PaymentService(), context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MonthlyProvider(PaymentService(), context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
            create: (context) => AttendanceProvider(
                AttendanceService(), context.read<TokenService>())),
        ChangeNotifierProvider(
            create: (context) => HolidayProvider(
                HolidayService(), context.read<TokenService>())),
        ChangeNotifierProvider(
            create: (context) =>
                WeekdayProvider(WeekdayService(), context.read<TokenService>()))
      ],
      child: MaterialApp(
        title: 'Teacher & Student App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/teacher': (context) => const TeacherHomeScreen(),
          '/student': (context) => const StudentHomeScreen(),
          '/holidays': (context) => const HolidayScreen(),
          '/about': (context) => const AboutScreen(),
        },
      ),
    );
  }
}
