import 'dart:typed_data';
import 'dart:developer';
import '../helpers/database_helper.dart';

class TeacherSettingsService {
  TeacherSettingsService();

  Future<Map<String, dynamic>> getSettings() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      DatabaseHelper.teacherSettingsTable,
      limit: 1,
    );

    if (result.isEmpty) {
      return {};
    }

    return result.first;
  }

  Future<void> updateBasicInfo({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final updates = <String, dynamic>{};

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;
    if (address != null) updates['address'] = address;

    if (updates.isNotEmpty) {
      await db.update(
        DatabaseHelper.teacherSettingsTable,
        updates,
        where: 'id = ?',
        whereArgs: [1],
      );
      log('Teacher basic info updated successfully');
    }
  }

  Future<void> updateReceiptSettings({
    String? header,
    String? footer,
    String? currencySymbol,
    String? terms,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final updates = <String, dynamic>{};

    if (header != null) updates['receiptHeader'] = header;
    if (footer != null) updates['receiptFooter'] = footer;
    if (currencySymbol != null) updates['currencySymbol'] = currencySymbol;
    if (terms != null) updates['terms'] = terms;

    if (updates.isNotEmpty) {
      await db.update(
        DatabaseHelper.teacherSettingsTable,
        updates,
        where: 'id = ?',
        whereArgs: [1],
      );
      log('Receipt settings updated successfully');
    }
  }

  Future<void> updateLogo(Uint8List logoBytes) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      DatabaseHelper.teacherSettingsTable,
      {'logo': logoBytes},
      where: 'id = ?',
      whereArgs: [1],
    );
    log('Logo updated successfully');
  }

  Future<void> updateSignature(Uint8List signatureBytes) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      DatabaseHelper.teacherSettingsTable,
      {'signature': signatureBytes},
      where: 'id = ?',
      whereArgs: [1],
    );
    log('Signature updated successfully');
  }

  Future<Uint8List?> getLogo() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      DatabaseHelper.teacherSettingsTable,
      columns: ['logo'],
      limit: 1,
    );

    if (result.isEmpty || result.first['logo'] == null) {
      return null;
    }

    return result.first['logo'] as Uint8List;
  }

  Future<Uint8List?> getSignature() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      DatabaseHelper.teacherSettingsTable,
      columns: ['signature'],
      limit: 1,
    );

    if (result.isEmpty || result.first['signature'] == null) {
      return null;
    }

    return result.first['signature'] as Uint8List;
  }

  Future<void> resetAllSettings() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(DatabaseHelper.teacherSettingsTable);
    await db.insert(DatabaseHelper.teacherSettingsTable, {
      'receiptHeader': 'PAYMENT RECEIPT',
      'currencySymbol': '₹',
    });
    log('All teacher settings reset to defaults');
  }
}