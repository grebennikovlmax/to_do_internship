import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskDatabase {

  Database _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database;
  }

  delete() async {
    return deleteDatabase(join(await getDatabasesPath(), 'task_database'));
  }

  Future<Database> _initDB() async {
    return openDatabase(
        join(await getDatabasesPath(), 'task_database'),
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE steps ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'description TEXT,'
              'is_completed INTEGER,'
              'task_id INTEGER,'
              'FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE'
              ')'
          );
          await db.execute('CREATE TABLE tasks ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'category_id INTEGER'
              'title TEXT,'
              'is_completed INTEGER,'
              'created_date INTEGER,'
              'notification_date INTEGER,'
              'final_date INTEGER,'
              'FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE'
              ')'
          );
          await db.execute('CREATE TABLE images ('
              'path TEXT PRIMARY KEY,'
              'task_id INTEGER,'
              'FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE'
              ')'
          );
          await db.execute('CREATE TABLE categories ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'title TEXT'
              ')'
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
        where: 'id = ?',
        whereArgs: [task['id']]
    );
    return res;
  }

  Future<List<Map<String, dynamic>>> queryAllTaskList(bool completed) async {
    final db = await database;
    final taskList = await db.query('tasks',
      where: 'is_completed = ?',
      whereArgs: [completed ? 1 : 0]
    );
    return taskList;
  }

  Future<int> removeCompletedTask() async {
    final db = await database;
    final res = await db.delete('tasks',
      where: 'is_completed = ?',
      whereArgs: [1]
    );
    return res;
  }

  Future<List<Map<String, dynamic>>> queryTaskList(int categoryId) async {
    final db = await database;
    final taskMap = await db.query('tasks',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return  taskMap;
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    final res = await db.delete("tasks",
      where: "id = ?",
      whereArgs: [id]
    );
    return res;

  }

  Future<int> insertStep(Map<String, dynamic> step) async {
    final db = await database;
    final res = await db.insert('steps', step);
    return res;
  }

  Future<int> deleteStep(int id) async {
    final db = await database;
    final res = await db.delete("steps",
        where: "id = ?",
        whereArgs: [id]
    );
    return res;
  }

  Future<int> updateStep(Map<String, dynamic> step) async {
    final db = await database;
    final res = await db.update('steps',
        step,
        where: 'id = ?',
        whereArgs: [step['id']]
    );
    return res;
  }

  Future<List<Map<String, dynamic>>> queryStepList(int id) async {
    final db = await database;
    final stepMap = await db.query('steps',
        where: 'task_id = ?',
        whereArgs: [id]
    );
    return stepMap;
  }

  Future<int> insertImage(Map<String, dynamic> image) async {
    final db = await database;
    final res = await db.insert('images', image);
    return res;
  }

  Future<List<Map<String, dynamic>>> queryImages(int taskId) async {
    final db = await database;
    final imagesMap = await db.query('images',
        where: 'task_id = ?',
        whereArgs: [taskId]
    );
    return imagesMap;
  }

  Future<int> deleteImage(String path) async {
    final db = await database;
    final res = await db.delete('images',
        where: 'path = ?',
        whereArgs: [path]
    );
    return res;
  }

  Future<int> insertCategory(Map<String, dynamic> map) async {
    var db = await database;
    return await db.insert('categories', map);
  }

  Future<List<Map<String, dynamic>>> queryCategories() async {
    var db = await database;
    return await db.query('categories');
  }
}

