import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../../providers/backup_provider.dart';
import '../../../providers/teacher/attendance_provider.dart';
import '../../../providers/teacher/course_provider.dart';
import '../../../providers/teacher/holiday_provider.dart';
import '../../../providers/teacher/month_provider.dart';
import '../../../providers/teacher/payment_provider.dart';
import '../../../providers/teacher/student_provider.dart';
import '../../../providers/teacher/weekday_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/handle_errors.dart';
import '../../../utils/permission_handler_utils.dart';
import '../../../utils/show_custom_center_modal.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/confirmation_modal.dart';
import '../../common/theme_switcher.dart';
import '../../common/user_info_header.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _logout(BuildContext context) {
    showCustomDialog<bool>(
      context: context,
      child: const ConfirmationDialog(
        message: 'Do you want to logout from page?',
        confirmButtonText: 'Logout',
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          await authProvider.logout();

          Provider.of<AttendanceProvider>(context, listen: false).clearData();
          Provider.of<AuthProvider>(context, listen: false).clearData();
          Provider.of<CourseProvider>(context, listen: false).clearData();
          Provider.of<HolidayProvider>(context, listen: false).clearData();
          Provider.of<MonthlyProvider>(context, listen: false).clearData();
          Provider.of<PaymentProvider>(context, listen: false).clearData();
          Provider.of<StudentProvider>(context, listen: false).clearData();
          Provider.of<WeekdayProvider>(context, listen: false).clearData();

          Navigator.of(context).pushReplacementNamed('/login');
        } catch (e) {
          handleErrors(context, e);
        }
      }
    });
  }

  Future<void> _handleExport(BuildContext context) async {
    final backupProvider = Provider.of<BackupProvider>(context, listen: false);
    final jsonData = await backupProvider.exportData();

    if (jsonData == null) {
      showCustomSnackBar(context, 'No data available to export');
      return;
    }

    final exportedFilePath = await FilePickerHelper.saveJsonToFile(
      jsonData,
      fileName: 'tuition_manager_backup.json',
      context: context,
    );

    if (exportedFilePath != null) {
      showCustomSnackBar(context, 'File is written to $exportedFilePath');
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final backupProvider = Provider.of<BackupProvider>(context, listen: false);
    final json = await FilePickerHelper.importBackupJsonFile(context);

    if (json != null) {
      try {
        final success = await backupProvider.importData(json);
        showCustomSnackBar(
          context,
          success ? 'Data imported successfully' : 'Failed to import data',
        );
      } catch (e) {
        showCustomSnackBar(context, 'Import error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const UserInfoHeader(),
                ListTile(
                  title: Text('My Holidays', style: theme.textTheme.bodyLarge),
                  onTap: () =>
                      Navigator.pushNamed(context, '/teacher/holidays'),
                ),
                ListTile(
                  title: Text('Export Data', style: theme.textTheme.bodyLarge),
                  onTap: () => _handleExport(context),
                ),
                ListTile(
                  title: Text('Import Data', style: theme.textTheme.bodyLarge),
                  onTap: () => _handleImport(context),
                ),
                const Divider(),
                ListTile(
                  title: Text('About', style: theme.textTheme.bodyLarge),
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
                ListTile(
                  title: Text('Logout', style: theme.textTheme.bodyLarge),
                  onTap: () => _logout(context),
                ),
                const Divider(),
              ],
            ),
          ),
          const ThemeSwitcher(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
