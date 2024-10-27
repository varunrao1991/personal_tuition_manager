import 'package:flutter/material.dart';
import './routes/admin_routes.dart';
import 'providers/theme_provider.dart';
import 'routes/navigator.dart';
import 'screens/common/about_screen.dart';
import 'screens/common/forgot_password_screen.dart';
import 'constants/app_theme.dart';
import 'providers/notification_provider.dart';
import 'providers/admin/teacher_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/common/change_password_screen.dart';
import 'screens/common/notification_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/admin/teacher_service.dart';
import 'services/token_service.dart';
import 'utils/http_client.dart';

class MyApp extends StatelessWidget {
  final String userType;

  const MyApp({super.key, required this.userType});

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
                AuthService(context.read<HttpTimeoutClient>(), 'admin'),
                context.read<TokenService>()),
          ),
          ChangeNotifierProvider(
            create: (context) => TeacherProvider(
                TeacherService(context.read<HttpTimeoutClient>()),
                context.read<TokenService>()),
          ),
          ChangeNotifierProvider(
            create: (context) => NotificationProvider(
                NotificationService(context.read<HttpTimeoutClient>()),
                context.read<TokenService>()),
          ),
          ChangeNotifierProvider(
            create: (context) {
              final themeProvider = ThemeProvider();
              themeProvider.loadThemePreference();
              return themeProvider;
            },
          )
        ],
        child:
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          return MaterialApp(
              navigatorKey: navigatorKey,
              navigatorObservers: [RouteObserver()],
              title: 'Admin App',
              themeMode: themeProvider.themeMode,
              theme: const MaterialTheme().light(),
              darkTheme: const MaterialTheme().dark(),
              initialRoute: '/login',
              routes: {
                ...adminRoutes,
                '/forgot-password': (context) => const ForgotPasswordScreen(),
                '/about': (context) => const AboutScreen(),
                '/notification': (context) => const NotificationScreen(),
                '/change-password': (context) => const ChangePasswordScreen(),
              });
        }));
  }
}
