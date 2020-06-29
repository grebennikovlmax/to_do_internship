import 'package:todointernship/data/ImageManager.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/data/task_data/task_db.dart';
import 'package:todointernship/model/task_image.dart';

abstract class TaskRepository {
  Future<List<Task>> getTaskList(bool completedIsHidden);
  Future<int> removeCompletedTask();
  Future<int> saveTask(Task task);
  Future<int> updateTask(Task task);
  Future<int> removeTask(int id);
  Future<int> saveStep(TaskStep step);
  Future<int> updateStep(TaskStep step);
  Future<int> removeStep(int id);
  Future<void> removeImage(String path);
  Future<List<TaskImage>> fetchImagesForTask(int taskId);
  Future<int> saveImage({String url, int taskId});
}

class TaskDatabaseRepository implements TaskRepository {

  static final shared = TaskDatabaseRepository();

  final TaskDatabase db = TaskDatabase();

  @override
  Future<int> saveTask(Task task) async {
    final map = _taskToMap(task);
    final res = await db.insertTask(map);
    return res;
  }

  Future<int> updateTask(Task task) async {
    final map = _taskToMap(task);
    final res = await db.updateTask(map);
    return res;
  }

  Future<int> removeTask(int id) async {
    final res = await db.deleteTask(id);
    return res;
  }



  @override
  Future<List<Task>> getTaskList(bool completedIsHidden) async {
    final tasks = completedIsHidden ? await db.queryIncompletedTaskList() : await db.queryTaskList();
    final taskWS =  await Future.wait(tasks.map((task) async {
      final taskWithSteps = Map<String, dynamic>.from(task);
      final steps = await db.queryStepList(task['id']);
      final List<TaskStep> stepList = steps.isEmpty ? [] : steps.map((step) => _mapToStep(step)).toList();
      taskWithSteps['steps'] = stepList;
      return taskWithSteps;
    }));
    return taskWS.map((e) => _mapToTask(e)).toList();
  }

  @override
  Future<int> removeCompletedTask() {
    final res = db.removeCompletedTask();
    return res;
  }

  @override
  Future<int> saveStep(TaskStep step) {
    final stepMap = _stepToMap(step);
    final res = db.insertStep(stepMap);
    return res;
  }

  @override
  Future<int> updateStep(TaskStep step) {
    final stepMap = _stepToMap(step);
    final res = db.updateStep(stepMap);
    return res;
  }

  @override
  Future<int> removeStep(int id) {
    final res = db.deleteStep(id);
    return res;
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

  deleteDB() {
    db.delete();
  }

  Map<String, dynamic> _taskToMap(Task task) {
    Map<String, dynamic> taskMap = {
      'title' : task.name,
      'is_completed': task.isCompleted ? 1 : 0,
      'created_date': task.createdDate.millisecondsSinceEpoch,
      'final_date': task.finalDate.millisecondsSinceEpoch,
      'id': task.id,
    };
    if(task.notificationDate != null) {
      taskMap['notification_date'] = task.notificationDate.millisecondsSinceEpoch;
    }
    return taskMap;
  }

  Task _mapToTask(Map<String, dynamic> map) {
    final task = Task(
        name: map['title'],
        id: map['id'],
        finalDate: DateTime.fromMillisecondsSinceEpoch(map['final_date']),
        createdDate: DateTime.fromMillisecondsSinceEpoch(map['created_date']),
        isCompleted: map['is_completed'] == 0 ? false : true,
        notificationDate: map['notification_date'] == null ? null : DateTime.fromMillisecondsSinceEpoch(map['notification_date']),
        steps: map['steps']
    );
    return task;
  }

  TaskStep _mapToStep(Map<String, dynamic> map) {
    return TaskStep(
      id: map['id'],
      taskID: map['task_id'],
      description: map['description'],
      isCompleted: map['is_completed'] == 1 ? true : false
    );
  }

  Map<String, dynamic> _stepToMap(TaskStep step) {
    Map<String, dynamic> stepMap = {
      'description' : step.description,
      'is_completed' : step.isCompleted ? 1 : 0,
      'task_id' : step.taskID
    };
    if(step.id != null) {
      stepMap['id'] = step.id;
    }
    return stepMap;
  }
}

