import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskDatabase {

  Database _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database;
  }

  delete() async {
    return deleteDatabase(join(await getDatabasesPath(), "task_database"));
  }

  Future<Database> _initDB() async {
    return openDatabase(
        join(await getDatabasesPath(), "task_database"),
        onCreate: (db, version) async {
          await db.execute("CREATE TABLE steps ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "description TEXT,"
              "is_completed INTEGER,"
              "task_id INTEGER,"
              "FOREIGN KEY(task_id) REFERENCES tasks(id)"
              ")"
          );
          await db.execute("CREATE TABLE tasks ("
              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "title TEXT,"
              "is_completed INTEGER,"
              "created_date INTEGER,"
              "final_date INTEGER"
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
    final res = await db.update('tasks',
        task,
        where: "id = ?",
        whereArgs: [task["id"]]
    );
    return res;
  }

  Future<List<Map<String, dynamic>>> queryTaskList() async {
    final db = await database;
    final taskMap = await db.query('tasks');
    return taskMap;
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    final res = await db.delete("tasks",
      where: "id = ?",
      whereArgs: [id]
    );
    return res;

  }
}

