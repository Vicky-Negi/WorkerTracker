import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database_name.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Actions (
        id INTEGER PRIMARY KEY,
        name TEXT,
        payPerMonth REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE AbsentDates (
        id INTEGER PRIMARY KEY,
        actionId INTEGER,
        date TEXT,
        FOREIGN KEY (actionId) REFERENCES Actions(id)
      )
    ''');
  }
    Future<int> insertAction(Action action) async {
    Database db = await instance.database;
    return await db.insert('Actions', action.toMap());
  }

  Future<int> insertAbsentDate(AbsentDate absentDate) async {
    Database db = await instance.database;
    return await db.insert('AbsentDates', absentDate.toMap());
  }
  
}
