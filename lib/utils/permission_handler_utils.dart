import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/confirmation_modal.dart';
import 'show_custom_center_modal.dart';

class FilePickerHelper {
  static Future<String?> pickAndReadJsonFile(BuildContext context) async {
    try {
      await _requestStoragePermission(context);
      await FilePicker.platform.clearTemporaryFiles();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        final content = String.fromCharCodes(result.files.single.bytes!);
        return content;
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

  static Future<String?> saveJsonToFile(
    String jsonContent, {
    String fileName = 'tuition_manager_backup.json',
    BuildContext? context,
    String? initialDirectory,
  }) async {
    try {
      if (context != null) {
        await _requestStoragePermission(context);
      }
      // Convert JSON content to bytes
      final bytes = Uint8List.fromList(jsonContent.codeUnits);

      // Open the Save File dialog to choose the file location and name
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: fileName,
        initialDirectory: initialDirectory,
        bytes: bytes,
      );

      // Check if the user cancelled the dialog
      if (path == null) {
        log('User canceled the save dialog');
        return null;
      }
      return path;
    } catch (e) {
      log('Error saving file: $e');
      if (context != null && context.mounted) {
        await _showErrorDialog(
          context,
          'Error',
          'Failed to save file: ${e.toString()}',
        );
      }
      return null;
    }
  }

  static Future<void> _requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          if (context.mounted) {
            final shouldOpenSettings = await showCustomDialog<bool>(
              context: context,
              child: const ConfirmationDialog(
                title: 'Storage Permission Required',
                message:
                    'This app needs storage permission to access files. Please grant the permission in the app settings.',
                confirmButtonText: 'Open Settings',
                cancelButtonText: 'Cancel',
              ),
            );
            if (shouldOpenSettings == true) {
              await openAppSettings();
            }
            // It's important to handle the case where the user cancels or doesn't grant permission.
            // You might want to throw an error or return a specific value to indicate failure.
            throw Exception('Storage permission permanently denied by the user.');
          }
        } else {
          status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            if (context.mounted) {
              await _showErrorDialog(
                context,
                'Storage Permission Denied',
                'Storage permission is required to access files.',
              );
            }
            throw Exception('Storage permission denied by the user.');
          }
        }
      }
    }
    // On iOS, FilePicker usually handles permissions.
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