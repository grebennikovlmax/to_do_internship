import 'package:todointernship/model/task.dart';

import 'package:todointernship/data/task_data/task_db.dart';

abstract class TaskRepository {
  Future<List<Task>> getTaskList(bool completedIsHidden);
  Future<void> removeCompletedTask();
  Future<void> updateTask(Task task);
  Future<void> removeTask(int id);
  Future<void> updateStep(TaskStep step);
  Future<void> removeStep(int id);
  // Возвращает id при сохранение в БД
  Future<int> saveTask(Task task);
  Future<int> saveStep(TaskStep step);
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
  Future<List<Task>> getTaskList(bool completedIsHidden) async {
    final tasks = completedIsHidden ? await db.queryIncompletedTaskList() : await db.queryTaskList();
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

}

