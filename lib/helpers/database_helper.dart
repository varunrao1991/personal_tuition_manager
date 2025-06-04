import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

class DatabaseHelper {
  final _databaseName = Config().appDb;
  static const int _databaseVersion = 4; // Updated from 3 to 4

  static const attendanceTable = 'Attendance';
  static const userTable = 'User';
  static const paymentTable = 'Payment';
  static const holidayTable = 'Holiday';
  static const courseTable = 'Course';
  static const weekdayTable = 'Weekday';
  static const teacherSettingsTable = 'TeacherSettings';

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database == null || !_database!.isOpen) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase({bool forceDelete = false}) async {
    log('_initDatabase');

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    if (forceDelete) {
      await deleteDatabase(path);
    }

    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );

    await _initializeTeacherSettings(db);
    return db;
  }

  Future<void> _onConfigure(Database db) async {
    log('_onConfigure');
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY,
        name TEXT,
        mobile TEXT,
        email TEXT,
        createdAt TEXT,
        lastAttendedDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $attendanceTable (
        attendanceDate TEXT NOT NULL,
        studentId INTEGER NOT NULL,
        PRIMARY KEY (attendanceDate, studentId),
        FOREIGN KEY (studentId) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $paymentTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        paymentDate TEXT NOT NULL,
        studentId INTEGER,
        FOREIGN KEY (studentId) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $courseTable (
        paymentId INTEGER PRIMARY KEY,
        startDate TEXT,
        endDate TEXT,
        totalClasses INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (paymentId) REFERENCES $paymentTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $holidayTable (
        holidayDate TEXT PRIMARY KEY,
        reason TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $weekdayTable (
        id INTEGER PRIMARY KEY,
        isEnabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE $teacherSettingsTable (
        id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        logo BLOB,
        signature BLOB,
        receiptHeader TEXT DEFAULT 'PAYMENT RECEIPT',
        receiptFooter TEXT,
        currencySymbol TEXT DEFAULT '₹',
        terms TEXT
      )
    ''');

    await db.execute('PRAGMA foreign_keys = ON');
    await _initializeTeacherSettings(db);
  }

  Future<void> _initializeTeacherSettings(Database db) async {
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $teacherSettingsTable')) ??
        0;

    if (count == 0) {
      await db.insert(teacherSettingsTable, {
        'receiptHeader': 'PAYMENT RECEIPT',
        'currencySymbol': '₹',
      });
    }
  }

  Future<void> _insertDefaultWeekdays(Database db) async {
    final weekdays = [
      {'id': 1, 'isEnabled': 1}, // Sunday
      {'id': 2, 'isEnabled': 1}, // Monday
      {'id': 3, 'isEnabled': 1}, // Tuesday
      {'id': 4, 'isEnabled': 1}, // Wednesday
      {'id': 5, 'isEnabled': 1}, // Thursday
      {'id': 6, 'isEnabled': 1}, // Friday
      {'id': 7, 'isEnabled': 1}, // Saturday
    ];

    for (final day in weekdays) {
      await db.insert(weekdayTable, day,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $weekdayTable (
          id INTEGER PRIMARY KEY,
          isEnabled INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await _insertDefaultWeekdays(db);
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $teacherSettingsTable (
          id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
          name TEXT,
          phone TEXT,
          email TEXT,
          address TEXT,
          logo BLOB,
          signature BLOB,
          receiptHeader TEXT DEFAULT 'PAYMENT RECEIPT',
          receiptFooter TEXT,
          currencySymbol TEXT DEFAULT '₹',
          terms TEXT
        )
      ''');
      await _initializeTeacherSettings(db);
    }

    // New migration for version 4 - Add lastAttendedDate column
    if (oldVersion < 4) {
      await db.execute('''
          ALTER TABLE $userTable ADD COLUMN lastAttendedDate TEXT DEFAULT NULL
      ''');

      // Populate lastAttendedDate for existing users based on their latest attendance
      await _populateLastAttendedDates(db);
    }
  }

  // Helper method to populate lastAttendedDate for existing users
  Future<void> _populateLastAttendedDates(Database db) async {
    try {
      log('Populating lastAttendedDate for existing users...');

      // Get all users with their latest attendance date
      final result = await db.rawQuery('''
        SELECT u.id, MAX(a.attendanceDate) as lastAttended
        FROM $userTable u
        LEFT JOIN $attendanceTable a ON u.id = a.studentId
        GROUP BY u.id
      ''');

      // Update each user's lastAttendedDate
      for (final row in result) {
        final userId = row['id'] as int;
        final lastAttended = row['lastAttended'] as String?;

        if (lastAttended != null) {
          await db.update(
            userTable,
            {'lastAttendedDate': lastAttended},
            where: 'id = ?',
            whereArgs: [userId],
          );
        }
      }

      log('Successfully populated lastAttendedDate for ${result.length} users');
    } catch (e) {
      log('Error populating lastAttendedDate: $e');
    }
  }

  // New method to update last attended date when attendance is marked
  Future<void> updateLastAttendedDate(
      int studentId, String? attendanceDate) async {
    if (attendanceDate != null) {
      // Validate date format
      try {
        DateTime.parse(attendanceDate);
      } catch (e) {
        throw FormatException('Invalid date format: $attendanceDate');
      }
    }

    final db = await database;
    await db.update(
      userTable,
      {'lastAttendedDate': attendanceDate},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  // Method to get users with their last attended date
  Future<List<Map<String, dynamic>>> getUsersWithLastAttendance() async {
    final db = await database;
    return await db.query(userTable);
  }

  // Method to get users who haven't attended for a specific number of days
  Future<List<Map<String, dynamic>>> getUsersNotAttendedSince(int days) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final cutoffDateString =
        cutoffDate.toIso8601String().split('T')[0]; // YYYY-MM-DD format

    return await db.query(
      userTable,
      where: 'lastAttendedDate IS NULL OR lastAttendedDate < ?',
      whereArgs: [cutoffDateString],
    );
  }

  // Teacher Settings Methods
  Future<Map<String, dynamic>> getTeacherSettings() async {
    final db = await database;
    final settings = await db.query(
      teacherSettingsTable,
      limit: 1,
    );
    return settings.isNotEmpty ? settings.first : {};
  }

  Future<int> updateTeacherSettings(Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update(
      teacherSettingsTable,
      updates,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> updateTeacherImage(
      {required Uint8List bytes, required bool isLogo // false for signature
      }) async {
    return await updateTeacherSettings({
      isLogo ? 'logo' : 'signature': bytes,
    });
  }

  Future<Uint8List?> getLogo() async {
    final settings = await getTeacherSettings();
    return settings['logo'] as Uint8List?;
  }

  Future<Uint8List?> getSignature() async {
    final settings = await getTeacherSettings();
    return settings['signature'] as Uint8List?;
  }

  // Original methods remain unchanged below...
  Future<String?> exportDatabaseToJson() async {
    Database? db;
    try {
      db = await database;
      final Map<String, dynamic> data = {};

      final tables = [
        userTable,
        attendanceTable,
        paymentTable,
        courseTable,
        holidayTable,
        weekdayTable,
        teacherSettingsTable,
      ];

      for (final table in tables) {
        try {
          final List<Map<String, dynamic>> tableData = await db.query(table);
          data[table] = tableData;
        } catch (e) {
          log('Error exporting table $table: $e');
          data[table] = [];
        }
      }

      data['version'] = _databaseVersion;

      return jsonEncode(data);
    } catch (e) {
      log('Error exporting database: $e');
      return null;
    } finally {
      if (db != null && db.isOpen) {
        await db.close();
        _database = null;
      }
    }
  }

  Future<bool> importDatabaseFromJson(String jsonString) async {
    Database? tempDb;
    Database? mainDb;

    try {
      final Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(jsonString);
      } catch (e) {
        log('❌ Invalid JSON format: $e');
        return false;
      }

      final dynamic versionData = jsonData['version'];
      final int importedVersion = versionData is int ? versionData : 0;

      // Allow importing from version 3 or 4 (backward compatibility)
      if (importedVersion < 3 || importedVersion > _databaseVersion) {
        log('❌ Database version mismatch. Current: $_databaseVersion, Imported: $importedVersion');
        return false;
      }

      final tempPath = join((await getApplicationDocumentsDirectory()).path,
          'temp_${Config().appDb}');
      tempDb = await openDatabase(tempPath,
          version: _databaseVersion, onCreate: _onCreate);

      final importOrder = [
        userTable,
        paymentTable,
        attendanceTable,
        courseTable,
        holidayTable,
        weekdayTable,
        teacherSettingsTable,
      ];

      final dateTimeFields = {
        userTable: ['createdAt'],
      };

      final dateFields = {
        attendanceTable: ['attendanceDate'],
        courseTable: ['startDate', 'endDate'],
        paymentTable: ['paymentDate'],
        holidayTable: ['holidayDate'],
        userTable: ['lastAttendedDate'], // Add lastAttendedDate as a date field
      };

      bool isValidDate(dynamic value) {
        if (value == null || value is! String) return false;
        try {
          DateTime.parse(value);
          return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);
        } catch (_) {
          return false;
        }
      }

      bool isValidDateTime(dynamic value) {
        if (value == null || value is! String) return false;
        try {
          DateTime.parse(value);
          return RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$')
              .hasMatch(value);
        } catch (_) {
          return false;
        }
      }

      for (final table in importOrder) {
        final dynamic tableData = jsonData[table];
        if (tableData is List) {
          for (int i = 0; i < tableData.length; i++) {
            final row = tableData[i];
            if (row is Map<String, dynamic>) {
              // Handle backward compatibility - if importing from version 3,
              // lastAttendedDate column won't exist in the data
              if (table == userTable && importedVersion < 4) {
                // Don't validate lastAttendedDate for older versions
              } else {
                for (final field in (dateFields[table] ?? [])) {
                  final value = row[field];
                  if (value != null && !isValidDate(value)) {
                    throw FormatException(
                        'Invalid date format for $field in table $table: $value');
                  }
                }
              }

              for (final field in (dateTimeFields[table] ?? [])) {
                final value = row[field];
                if (value != null && !isValidDateTime(value)) {
                  throw FormatException(
                      'Invalid datetime format for $field in table $table: $value');
                }
              }

              try {
                await tempDb.insert(table, row,
                    conflictAlgorithm: table == teacherSettingsTable
                        ? ConflictAlgorithm.replace
                        : ConflictAlgorithm.abort);
              } catch (e) {
                log('❌ Error inserting record #${i + 1} into $table:');
                log('   Record data: $row');
                log('   Error details: $e');
                rethrow;
              }
            } else {
              throw FormatException(
                  'Invalid data format in table $table at index $i');
            }
          }
        }
      }

      log('✅ Validation successful, beginning main import...');
      mainDb = await _initDatabase(forceDelete: true);

      for (final table in importOrder) {
        final dynamic tableData = jsonData[table];
        if (tableData is List) {
          const batchSize = 50;
          for (int batchStart = 0;
              batchStart < tableData.length;
              batchStart += batchSize) {
            final batchEnd = (batchStart + batchSize) < tableData.length
                ? (batchStart + batchSize)
                : tableData.length;
            final batch = mainDb.batch();

            for (int i = batchStart; i < batchEnd; i++) {
              batch.insert(table, tableData[i] as Map<String, dynamic>,
                  conflictAlgorithm: table == teacherSettingsTable
                      ? ConflictAlgorithm.replace
                      : ConflictAlgorithm.abort);
            }

            try {
              await batch.commit(noResult: true);
            } catch (e) {
              log('❌ Batch insert failed for table $table between records ${batchStart + 1}-$batchEnd');
              for (int i = batchStart; i < batchEnd; i++) {
                try {
                  await mainDb.insert(
                      table, tableData[i] as Map<String, dynamic>,
                      conflictAlgorithm: table == teacherSettingsTable
                          ? ConflictAlgorithm.replace
                          : ConflictAlgorithm.abort);
                } catch (e) {
                  log('  Failed record #${i + 1}: ${tableData[i]}');
                  log('  Error: $e');
                }
              }
              rethrow;
            }
          }
        }
      }

      // If imported from version 3, populate lastAttendedDate for existing users
      if (importedVersion < 4) {
        await _populateLastAttendedDates(mainDb);
      }

      log('🎉 Database import completed successfully!');
      await _database?.close();
      _database = mainDb;
      return true;
    } catch (e) {
      log('❌ Database import failed: $e');
      return false;
    } finally {
      if (tempDb != null && tempDb.isOpen) {
        await tempDb.close();
        await deleteDatabase(tempDb.path);
      }
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
