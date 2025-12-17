import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled1/model/expense.dart';

class DbHelper {
  static const int _version = 3;
  static const String _dbName = "Expenses";

  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE expense(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL
      )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS expense');
          await db.execute('''
        CREATE TABLE expense(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          category TEXT NOT NULL
        )
        ''');
        }
      },
    );
  }

  static Future<int> addExpense(Expense expense) async {
    Database db = await _getDB();
    return await db.insert(
      "expense",
      expense.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateExpense(Expense expense) async {
    Database db = await _getDB();
    return await db.update(
      "expense",
      expense.toJson(),
      where: "id = ?",
      whereArgs: [expense.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> deleteExpense(Expense expense) async {
    Database db = await _getDB();
    return await db.delete(
      "expense",
      where: "id = ?",
      whereArgs: [expense.id],
    );
  }

  static Future<List<Expense>> getExpenses() async {
    Database db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("expense");
    return List.generate(maps.length, (index) {
      return Expense.fromJson(maps[index]);
    });
  }
}
