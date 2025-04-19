import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

class DatabaseHelper {
  final _databaseName = Config().appDb;
  static const int _databaseVersion = 1;

  static const attendanceTable = 'Attendance';
  static const userTable = 'User';
  static const paymentTable = 'Payment';
  static const holidayTable = 'Holiday';
  static const courseTable = 'Course';

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
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
        attendanceDate TEXT,
        studentId INTEGER,
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

    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Placeholder: Add migration logic here when schema changes in future versions
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
