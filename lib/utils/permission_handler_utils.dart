import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../widgets/confirmation_modal.dart';
import 'show_custom_center_modal.dart';
import 'package:path/path.dart' as path; // Import path package

class FilePickerHelper {
  static Future<String?> pickAndReadJsonFile(BuildContext context,
      {List<String> allowedExtensions = const ['json']}) async {
    try {
      await FilePicker.platform.clearTemporaryFiles();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path;
        final file = File(filePath!);
        if (await file.exists()) {
          return await file.readAsString();
        }
      }
      return null;
    } catch (e) {
      log('Error during file picking: $e');
      if (context.mounted) {
        await _showErrorDialog(context, 'File Selection Error',
            'Unable to read file: ${e.toString()}');
      }
      return null;
    }
  }

  // ==================== SAVE TO JSON ====================
  static Future<String?> saveJsonToFile(String jsonContent,
      {String fileName = 'backup_export.json', BuildContext? context}) async {
    try {
      final directory = await _getPublicDirectory();

      if (directory == null) {
        log('Could not get public directory');
        if (context != null && context.mounted) {
          await _showErrorDialog(
              context, 'Error', 'Unable to access public storage directory.');
        }
        return null;
      }

      // Make sure the directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonContent);
      log('File saved to: ${file.path}');
      return file.path;
    } catch (e) {
      log('Error saving file: $e');
      if (context != null && context.mounted) {
        await _showErrorDialog(
            context, 'Error', 'Failed to save file: ${e.toString()}');
      }
      return null;
    }
  }

  // ==================== IMPORT BACKUP JSON ====================
  static Future<String?> importBackupJsonFile(BuildContext context,
      {String fileName = 'tuition_manager_backup.json'}) async {
    try {
      final directory = await _getPublicDirectory();

      if (directory == null) {
        log('Could not get public directory for import');
        if (context.mounted) {
          await _showErrorDialog(context, 'Error',
              'Unable to access public storage directory for import.');
        }
        return null;
      }
      log(directory.path);
      final targetFile = File(path.join(directory.path, fileName));

      if (await targetFile.exists()) {
        return await targetFile.readAsString();
      } else {
        if (context.mounted) {
          await _showErrorDialog(
              context, 'Import Error', 'Backup file "$fileName" not found.');
        }
        return null;
      }
    } catch (e) {
      log('Error during backup file import: $e');
      if (context.mounted) {
        await _showErrorDialog(context, 'Import Error',
            'Failed to import backup file: ${e.toString()}');
      }
      return null;
    }
  }

  /// Returns a publicly accessible directory based on platform
  static Future<Directory?> _getPublicDirectory() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        final status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          final result = await Permission.manageExternalStorage.request();
          if (!result.isGranted) {
            log('MANAGE_EXTERNAL_STORAGE permission denied');
            return null;
          }
        }
        return Directory('/storage/emulated/0/Download');
      } else {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          final result = await Permission.storage.request();
          if (!result.isGranted) {
            log('WRITE_EXTERNAL_STORAGE permission denied');
            return null;
          }
        }

        final directories = await getExternalStorageDirectories();
        if (directories != null && directories.isNotEmpty) {
          String path = directories[0].path;
          final List<String> pathSegments = path.split('/');
          int index = pathSegments.indexOf('Android');
          if (index != -1) {
            pathSegments.removeRange(index, pathSegments.length);
            path = pathSegments.join('/');
            return Directory('$path/Download');
          }
          return directories[0];
        }

        return Directory('/storage/emulated/0/Download');
      }
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory;
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  static Future<bool> requestStoragePermission(BuildContext? context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 30) {
        return await _requestManageExternalStorage(context);
      } else {
        return await _requestStoragePermission(context);
      }
    }
    return true; // iOS doesn't need explicit permission for app documents
  }

  static Future<bool> _requestManageExternalStorage(
      BuildContext? context) async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    if (context != null && context.mounted) {
      final shouldOpenSettings = await showCustomDialog<bool>(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Storage Permission Required',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppPaddings.mediumPadding),
            const Text(
              'To save files that other apps can access, please grant "Files and media" permission in Settings.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppPaddings.largePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Settings'),
                ),
              ],
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
    }

    // Check again after user might have changed permissions
    return await Permission.manageExternalStorage.status.isGranted;
  }

  static Future<bool> _requestStoragePermission(BuildContext? context) async {
    final status = await Permission.storage.request();
    if (status.isGranted) return true;

    if (context != null && context.mounted) {
      final shouldOpenSettings = await showCustomDialog<bool>(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Storage Permission Required',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppPaddings.mediumPadding),
            const Text(
              'To save files that other apps can access, please grant storage permission.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppPaddings.largePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Settings'),
                ),
              ],
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
    }

    // Check again after user might have changed permissions
    return await Permission.storage.status.isGranted;
  }

  static Future<void> _showErrorDialog(
      BuildContext context, String title, String message) async {
    showCustomDialog<bool>(
      context: context,
      child: ConfirmationDialog(
        title: title,
        message: message,
        confirmButtonText: 'Ok',
      ),
    );
  }
}
