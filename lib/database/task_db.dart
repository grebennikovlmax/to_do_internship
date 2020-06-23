import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskDatabase {

  Database _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    return openDatabase(
        join(await getDatabasesPath(), "task_database"),
        onCreate: (db, version) async {
          await db.execute("CREATE TABLE steps ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "description TEXT,"
              "is_completed INTEGER,"
              "task_id id,"
              "FOREIGN KEY(task_id) REFERENCES tasks(id)"
              ")"
          );
          await db.execute("CREATE TABLE tasks ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "title TEXT,"
              "is_completed INTEGER,"
              "created_date TEXT,"
              "final_date TEXT"
              ")"
          );
        },
      version: 1
    );
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    final res = await db.insert('tasks', task);
    return res;
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    final res = await db.update('tasks', task);
    return res;
  }

  Future<List<Map<String, dynamic>>> queryTaskList() async {
    final db = await database;
    final taskMap = await db.query('tasks');
    return taskMap;
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    final res = await db.delete(table)

  }
}

