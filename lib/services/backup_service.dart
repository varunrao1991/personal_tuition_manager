import 'dart:developer';
import '../../helpers/database_helper.dart';

class BackupService {
  Future<String?> exportData() async {
    try {
      return await DatabaseHelper.instance.exportDatabaseToJson();
    } catch (e) {
      log('Export error: $e');
      return null;
    }
  }

  Future<bool> importData(String jsonString) async {
    try {
      return await DatabaseHelper.instance.importDatabaseFromJson(jsonString);
    } catch (e) {
      log('Import error: $e');
      return false;
    }
  }
}
