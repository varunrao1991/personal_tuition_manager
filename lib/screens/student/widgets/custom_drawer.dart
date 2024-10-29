// Update in your original file (e.g., student_custom_drawer.dart)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/user_info_header.dart';
import '../../../providers/student/attendance_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student/course_provider.dart';
import '../../../providers/student/holiday_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/student/weekday_provider.dart';
import '../../../utils/handle_errors.dart';
import '../../../widgets/confirmation_modal.dart';
import '../../../utils/show_custom_center_modal.dart';
import '../../common/theme_switcher.dart';

class StudentCustomDrawer extends StatelessWidget {
  const StudentCustomDrawer({super.key});

  void _logout(BuildContext context) {
    showCustomDialog<bool>(
      context: context,
      child: const ConfirmationDialog(
        message: 'Do you want to logout from page?',
        confirmButtonText: 'Logout',
      ),
    ).then((success) async {
      if (success != null && success) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        try {
          await authProvider.logout();

          Provider.of<AttendanceProvider>(context, listen: false).clearData();
          Provider.of<AuthProvider>(context, listen: false).clearData();
          Provider.of<CourseProvider>(context, listen: false).clearData();
          Provider.of<HolidayProvider>(context, listen: false).clearData();
          Provider.of<NotificationProvider>(context, listen: false).clearData();
          Provider.of<WeekdayProvider>(context, listen: false).clearData();

          Navigator.of(context).pushReplacementNamed('/login');
        } catch (e) {
          handleErrors(context, e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserInfoHeader(),
          ListTile(
            title: Text(
              'About',
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            title: Text(
              'Logout',
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              _logout(context);
            },
          ),
          const Divider(),
          const ThemeSwitcher(),
        ],
      ),
    );
  }
}
