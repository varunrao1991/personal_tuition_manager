import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/student/attendance_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student/course_provider.dart';
import '../../../providers/student/holiday_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/student/weekday_provider.dart';
import '../../../utils/handle_errors.dart';
import '../../../widgets/confirmation_modal.dart';
import '../../../utils/show_custom_center_modal.dart';
import '../../common/edit_profile_screen.dart';
import '../../../providers/theme_provider.dart'; // Import ThemeProvider

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;

              return DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                child: SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '',
                            style: theme.textTheme.titleLarge!
                                .copyWith(color: theme.colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 3),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: theme.iconTheme.color,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
          const Divider(), // Add a divider for better organization
          Padding(
            padding: const EdgeInsets.all(8.0), // Add some padding around icons
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.light_mode),
                  tooltip: 'Light Theme',
                  onPressed: () {
                    themeProvider.toggleTheme(ThemeMode.light);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.dark_mode),
                  tooltip: 'Dark Theme',
                  onPressed: () {
                    themeProvider.toggleTheme(ThemeMode.dark);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.brightness_auto),
                  tooltip: 'System Default',
                  onPressed: () {
                    themeProvider.toggleTheme(ThemeMode.system);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
