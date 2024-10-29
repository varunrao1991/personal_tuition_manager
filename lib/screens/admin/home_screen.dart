import 'package:flutter/material.dart';
import '../../widgets/notification_widget.dart';
import 'teacher_screen.dart';
import 'widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: const [NotificationHandlerWidget()],
      ),
      drawer: const CustomDrawer(),
      body: const TeacherScreen(),
    );
  }
}
