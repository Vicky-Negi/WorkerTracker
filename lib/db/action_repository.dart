import 'package:sqflite/sqflite.dart';
import 'models.dart';
import 'database_helper.dart';

class DbOperations {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> insertAction(Action action) async {
    final Database db = await dbHelper.database;
    await db.insert('Actions', action.toMap());
  }
  Future<void> updateActionPayPerMonth(String actionName, double payPerMonth) async {
    final Database db = await dbHelper.database;
    await db.update(
      'Actions',
      {'payPerMonth': payPerMonth},
      where: 'name = ?',
      whereArgs: [actionName],
    );
    print(actionName);
  }

  Future<void> updateActionName(String oldName, String newName) async {
    final Database db = await dbHelper.database;
    await db.update(
      'Actions',
      {'name': newName},
      where: 'name = ?',
      whereArgs: [oldName],
    );
  }

  Future<void> deleteAction(int id) async {
    final Database db = await dbHelper.database;
    await db.delete('Actions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Action>> getActions() async {
    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Actions');

    return List.generate(maps.length, (i) {
      return Action(
        id: maps[i]['id'],
        name: maps[i]['name'],
        payPerMonth: maps[i]['payPerMonth'],
      );
    });
  }
  
  Future<void> insertAbsentDate(AbsentDate absentDate) async {
    final Database db = await dbHelper.database;
    await db.insert('AbsentDates', absentDate.toMap());
  }

  Future<double> getPayPerMonthForAction(String actionName) async {
  final Database db = await dbHelper.database;
  List<Map<String, dynamic>> result = await db.query(
    'Actions',
    columns: ['payPerMonth'],
    where: 'name = ?',
    whereArgs: [actionName],
  );

  if (result.isNotEmpty) {
    return result.first['payPerMonth'] as double;
  } else {
    return 0; // Return 0 if pay per month is not set for the action
  }
}
Future<List<String>> getAllActions() async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('Actions');
    return List.generate(maps.length, (index) {
      return maps[index]['name'] as String;
    });
  }
  // Add more methods for CRUD operations on AbsentDates or other tables...
}
