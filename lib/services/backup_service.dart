import 'dart:developer';

import '../helpers/database_helper.dart';

class BackupService {
  Future<String?> exportData() async {
    try {
      // Use the new DatabaseService instead of direct DatabaseHelper access
      return await DatabaseHelper.instance.exportDatabaseToJson();
    } catch (e, stackTrace) {
      log('Export error', 
          error: e, 
          stackTrace: stackTrace,
          name: 'BackupService');
      return null;
    }
  }

  Future<bool> importData(String jsonString) async {
    try {
      // Use the new DatabaseService for proper connection management
      final success = await  DatabaseHelper.instance.importDatabaseFromJson(jsonString);
      
      if (!success) {
        log('Import failed - version mismatch or data corruption',
            name: 'BackupService');
        return false;
      }
      
      return true;
    } catch (e, stackTrace) {
      log('Import error', 
          error: e, 
          stackTrace: stackTrace,
          name: 'BackupService');
      return false;
    }
  }
}