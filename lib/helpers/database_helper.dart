import 'dart:convert';
import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

class DatabaseHelper {
  final _databaseName = Config().appDb;
  static const int _databaseVersion = 2;

  static const attendanceTable = 'Attendance';
  static const userTable = 'User';
  static const paymentTable = 'Payment';
  static const holidayTable = 'Holiday';
  static const courseTable = 'Course';
  static const weekdayTable = 'Weekday';

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
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    if (forceDelete) {
      await deleteDatabase(path);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY,
        name TEXT,
        mobile TEXT,
        email TEXT,
        createdAt TEXT
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

    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _insertDefaultWeekdays(Database db) async {
    final weekdays = [
      {'id': 1, 'isEnabled': 1},
      {'id': 2, 'isEnabled': 1},
      {'id': 3, 'isEnabled': 1},
      {'id': 4, 'isEnabled': 1},
      {'id': 5, 'isEnabled': 1},
      {'id': 6, 'isEnabled': 1},
      {'id': 7, 'isEnabled': 1},
    ];

    for (final day in weekdays) {
      await db.insert(weekdayTable, day);
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
  }

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
      if (importedVersion != _databaseVersion) {
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
      ];

      final dateTimeFields = {
        userTable: ['createdAt'],
      };

      final dateFields = {
        attendanceTable: ['attendanceDate'],
        courseTable: ['startDate', 'endDate'],
        paymentTable: ['paymentDate'],
        holidayTable: ['holidayDate'],
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
              for (final field in (dateFields[table] ?? [])) {
                final value = row[field];
                if (value != null && !isValidDate(value)) {
                  throw FormatException(
                      'Invalid date format for $field in table $table: $value');
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
                await tempDb.insert(table, row);
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
              batch.insert(table, tableData[i] as Map<String, dynamic>);
            }

            try {
              await batch.commit(noResult: true);
            } catch (e) {
              log('❌ Batch insert failed for table $table between records ${batchStart + 1}-$batchEnd');
              for (int i = batchStart; i < batchEnd; i++) {
                try {
                  await mainDb.insert(
                      table, tableData[i] as Map<String, dynamic>);
                } catch (e) {
                  log('   Failed record #${i + 1}: ${tableData[i]}');
                  log('   Error: $e');
                }
              }
              rethrow;
            }
          }
        }
      }

      log('🎉 Database import completed successfully!');
      return true;
    } catch (e) {
      log('❌ Database import failed: $e');
      return false;
    } finally {
      if (tempDb != null && tempDb.isOpen) {
        await tempDb.close();
        await deleteDatabase(tempDb.path);
      }

      if (mainDb != null && !mainDb.isOpen) {
        _database = null;
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
