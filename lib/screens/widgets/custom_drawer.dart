import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/backup_provider.dart';
import '../../providers/major/attendance_provider.dart';
import '../../providers/major/course_provider.dart';
import '../../providers/major/holiday_provider.dart';
import '../../providers/major/month_provider.dart';
import '../../providers/major/payment_provider.dart';
import '../../providers/major/student_provider.dart';
import '../../providers/major/weekday_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../utils/permission_handler_utils.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/confirmation_modal.dart';
import '../common/theme_switcher.dart';
import '../common/user_info_header.dart';

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final backupProvider =
          Provider.of<BackupProvider>(context, listen: false);
      final jsonData = await backupProvider.exportData();

      if (jsonData == null) {
        Navigator.pop(context);
        showCustomSnackBar(context, 'No data available to export');
        return;
      }

      // Save file to app-specific storage
      final exportedFilePath = await FilePickerHelper.saveJsonToFile(
        jsonData,
        fileName: 'tuition_manager_backup.json',
        context: context,
      );

      Navigator.pop(context);
      if (exportedFilePath != null) {
        showCustomSnackBar(context, 'File exported.');
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, 'Export error: ${e.toString()}');
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final backupProvider = Provider.of<BackupProvider>(context, listen: false);
      final json = await FilePickerHelper.pickAndReadJsonFile(context);

      if (json != null) {
        final success = await backupProvider.importData(json);
        Navigator.pop(context);
        showCustomSnackBar(
          context,
          success ? 'Data imported successfully' : 'Failed to import data',
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, 'Import error: ${e.toString()}');
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
                  leading: const Icon(Icons.calendar_today),
                  onTap: () =>
                      Navigator.pushNamed(context, '/teacher/holidays'),
                ),
                ListTile(
                  title: Text('Subjects', style: theme.textTheme.bodyLarge),
                  leading: const Icon(Icons.subject),
                  onTap: () =>
                      Navigator.pushNamed(context, '/teacher/subjects'),
                ),
                ListTile(
                  title: Text('About', style: theme.textTheme.bodyLarge),
                  leading: const Icon(Icons.info),
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
                const Divider(),
                ListTile(
                  title: Text('Export Data', style: theme.textTheme.bodyLarge),
                  leading: const Icon(Icons.upload_file),
                  onTap: () => _handleExport(context),
                ),
                ListTile(
                  title: Text('Import Data', style: theme.textTheme.bodyLarge),
                  leading: const Icon(Icons.download_rounded),
                  onTap: () => _handleImport(context),
                ),
                const Divider(),
                ListTile(
                  title: Text('Logout', style: theme.textTheme.bodyLarge),
                  leading: const Icon(Icons.logout),
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