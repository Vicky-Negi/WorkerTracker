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

    // New method to initialize the database
  Future<Database> initializeDatabase(String path) async {
    if (_database != null) {
      return _database!;
    }
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
    return _database!;
  } 
  Future<Database> _initDatabase() async {
    
    String path = join(await getDatabasesPath(), 'worker_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

void _createDatabase(Database db, int version) async {
  await db.execute('''
    CREATE TABLE Actions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      payPerDay REAL
    )
  ''');

    // await db.execute('''
    //   CREATE TABLE AbsentDates (
    //     id INTEGER PRIMARY KEY,
    //     actionId INTEGER,
    //     date TEXT,
    //     FOREIGN KEY (actionId) REFERENCES Actions(id)
    //   )
    // ''');
    await db.execute('''
  CREATE TABLE AbsentDates (
    actionId INTEGER,
    date TEXT,
    PRIMARY KEY (actionId, date),
    FOREIGN KEY (actionId) REFERENCES Actions(id)
  )
''');

    await db.execute('''
      CREATE TABLE MonthlySummary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        actionId INTEGER,
        monthYear TEXT,
        absentDays INTEGER,
        totalPayable REAL,
        FOREIGN KEY (actionId) REFERENCES Actions(id)
      )
    ''');
  }

Future<int> insertAction(Action action) async {
  Database db = await instance.database;
  return await db.insert('Actions', action.toMap());
}


  Future<List<Action>> getActions() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> actionMaps = await db.query('Actions');
    return List.generate(actionMaps.length, (index) {
      return Action.fromMap(actionMaps[index]);
    });
  }

   Future<int> insertAbsentDate(AbsentDate absentDate) async {
    Database db = await instance.database;
    int rowsAffected = await db.insert('AbsentDates', absentDate.toMap());

    // Update MonthlySummary table with new data
    if (rowsAffected > 0) {
      // Calculate totalPayable and count absentDays for the month
      List<Map<String, dynamic>> absentDatesForMonth = await db.rawQuery(
        'SELECT COUNT(*) AS absentDays, SUM(Actions.payPerDay) AS totalPayable '
        'FROM AbsentDates '
        'JOIN Actions ON AbsentDates.actionId = Actions.id '
        'WHERE AbsentDates.actionId = ? AND strftime("%Y-%m", AbsentDates.date) = strftime("%Y-%m", ?)',
        [absentDate.actionId, absentDate.date],
      );

      int? absentDays = absentDatesForMonth[0]['absentDays'] ?? 0;
      double? totalPayable = absentDatesForMonth[0]['totalPayable'] ?? 0;

      String monthYear = absentDate.date.substring(0, 7); // Extract 'YYYY-MM' for the month and year

      // Check if a record for this month already exists
      List<Map<String, dynamic>> existingRecords = await db.query(
        'MonthlySummary',
        where: 'actionId = ? AND monthYear = ?',
        whereArgs: [absentDate.actionId, monthYear],
      );

      if (existingRecords.isEmpty) {
        // If no record exists for this month, insert a new record
        await db.insert('MonthlySummary', {
          'actionId': absentDate.actionId,
          'monthYear': monthYear,
          'absentDays': absentDays,
          'totalPayable': totalPayable,
        });
      } else {
        // If a record already exists, update the record
        await db.update(
          'MonthlySummary',
          {
            'absentDays': absentDays,
            'totalPayable': totalPayable,
          },
          where: 'actionId = ? AND monthYear = ?',
          whereArgs: [absentDate.actionId, monthYear],
        );
      }
    }

    return rowsAffected;
  }
  Future<void> insertOrUpdateAbsentDate(AbsentDate absentDate) async {
  Database db = await instance.database;

  await db.insert(
    'AbsentDates',
    absentDate.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace, // This line will replace the existing entry if there is a conflict
  );
}


  Future<List<AbsentDate>> getAbsentDatesForAction(int actionId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> absentDateMaps = await db.query(
      'AbsentDates',
      where: 'actionId = ?',
      whereArgs: [actionId],
    );
    return List.generate(absentDateMaps.length, (index) {
      return AbsentDate.fromMap(absentDateMaps[index]);
    });
  }
Future<int> updateActionName(String id, String newName) async {
  Database db = await instance.database;
  return await db.update(
    'Actions',
    {'name': newName},
    where: 'id = ?',
    whereArgs: [int.parse(id)], // Convert id from String to int
  );
}

Future<int> updatePayableAmountPerDay(int id, double newAmount) async {
  Database db = await instance.database;
  return await db.update(
    'Actions',
    {'payPerDay': newAmount}, // Update 'payPerDay' column
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> deleteAbsentDate(String id) async {
  Database db = await instance.database;
  return await db.delete(
    'AbsentDates',
    where: 'id = ?',
    whereArgs: [id],
  );
}
  Future<int> deleteAbsentDateByDate(int actionId, String date) async {
    // Method to delete an AbsentDate by actionId and date
    Database db = await instance.database;
    return await db.delete(
      'AbsentDates',
      where: 'actionId = ? AND date = ?',
      whereArgs: [actionId, date],
    );
  }
   Future<List<AbsentDate>> getAbsentDatesForMonth(int actionId, DateTime month) async {
    // Method to get AbsentDates for a specific month and actionId
    Database db = await instance.database;

    // Construct the start and end date for the given month
    DateTime startDate = DateTime(month.year, month.month, 1);
    DateTime endDate = DateTime(month.year, month.month + 1, 0);

    List<Map<String, dynamic>> results = await db.query(
      'AbsentDates',
      where: 'actionId = ? AND date BETWEEN ? AND ?',
      whereArgs: [actionId, startDate.toIso8601String(), endDate.toIso8601String()],
    );

    // Convert the retrieved database results to a list of AbsentDate objects
    List<AbsentDate> absentDates = results.map((map) => AbsentDate.fromMap(map)).toList();
    return absentDates;
  }

}
