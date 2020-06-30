import 'package:todointernship/data/ImageManager.dart';
import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/data/task_data/task_db.dart';
import 'package:todointernship/model/task_image.dart';

abstract class TaskRepository {
  Future<List<Task>> getTaskListForCategory(int id);
  Future<void> removeCompletedTask();
  Future<void> updateTask(Task task);
  Future<void> removeTask(int id);
  Future<void> updateStep(TaskStep step);
  Future<void> removeStep(int id);
  Future<void> removeImage(String path);
  Future<List<TaskImage>> fetchImagesForTask(int taskId);
  Future<List<Task>> getAllTask(bool completed);
  // Возвращает id при сохранение в БД
  Future<int> saveTask(Task task);
  Future<int> saveStep(TaskStep step);
  Future<int> saveCategory(Category category);
  Future<int> saveImage({String url, int taskId});
  Future<List<Category>> getAllCategories();
}

class TaskDatabaseRepository implements TaskRepository {

  static final shared = TaskDatabaseRepository();

  final TaskDatabase db = TaskDatabase();

  @override
  Future<int> saveTask(Task task) async {
    return await db.insertTask(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    return await db.updateTask(task.toMap());
  }

  Future<void> removeTask(int id) async {
    return await db.deleteTask(id);
  }



  @override
  Future<List<Task>> getTaskListForCategory(int id) async {
    final tasks = await db.queryTaskList();
    final taskWS =  await Future.wait(tasks.map((task) async {
      final taskWithSteps = Map<String, dynamic>.from(task);
      final steps = await db.queryStepList(task['id']);
      final List<TaskStep> stepList = steps.isEmpty ? [] : steps.map((step) => TaskStep.fromMap(step)).toList();
      taskWithSteps['steps'] = stepList;
      return taskWithSteps;
    }));
    return taskWS.map((e) => Task.fromMap(e)).toList();
  }

  @override
  Future<void> removeCompletedTask() async {
    return await db.removeCompletedTask();
  }

  @override
  Future<int> saveStep(TaskStep step) async {
    return await db.insertStep(step.toMap());
  }

  @override
  Future<void> updateStep(TaskStep step) async {
    return await db.updateStep(step.toMap());
  }

  @override
  Future<void> removeStep(int id) async {
    return await db.deleteStep(id);
  }

  @override
  Future<List<TaskImage>> fetchImagesForTask(int taskId) async {
    final data = await db.queryImages(taskId);
    return data.map((e) => TaskImage.fromMap(e)).toList();
  }

  @override
  Future<void> removeImage(String path) async {
    await db.deleteImage(path);
    await ImageManager.shared.removeImage(path);
  }

  @override
  Future<int> saveImage({String url, int taskId}) async {
    final path = await ImageManager.shared.saveImage(url);
    final image = TaskImage(taskID: taskId, path: path);
    final res = await db.insertImage(image.toMap());
    return res;
  }

  @override
  Future<List<Task>> getAllTask(bool completed) async {
    var taskMapList = await db.queryAllTaskList(completed);
    return taskMapList.map((e) => Task.fromMap(e)).toList();
  }

  @override
  Future<int> saveCategory(Category category) async {
    return await db.insertCategory(category.toMap());
  }

  @override
  Future<List<Category>> getAllCategories() async {
    var mapList = await db.queryCategories();
    return mapList.map((e) => Category.fromMap(e)).toList();
  }
}

