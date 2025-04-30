import 'package:flutter/material.dart';
import '../../services/backup_service.dart';

class BackupProvider with ChangeNotifier {
  final BackupService _backupService;

  BackupProvider(this._backupService);

  Future<String?> exportData() async {
    return await _backupService.exportData();
  }

  Future<bool> importData(String jsonString) async {
    return await _backupService.importData(jsonString);
  }
}
