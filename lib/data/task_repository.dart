import 'package:sqflite/sqflite.dart';
import 'package:todointernship/model/task.dart';

import 'package:todointernship/database/task_db.dart';

abstract class TaskRepository {
  Future<List<Task>> getTaskList();
  Future<List<Task>> getIncompletedListTask();
  Future<int> saveTask(Task task);
  Future<int> updateTask(Task task);
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

  @override
  Future<List<Task>> getIncompletedListTask() {
    // TODO: implement getIncompletedListTask
    throw UnimplementedError();
  }


  @override
  Future<List<Task>> getTaskList() async {
    final taskMap = await db.queryTaskList();
    print(taskMap.map((e) => _mapToTask(e)).toList());
    return taskMap.map((e) => _mapToTask(e)).toList();

  }

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      "title" : task.name,
      "is_completed": task.isCompleted ? 1 : 0,
      "created_date": task.createdDate.toString(),
      "final_date": task.finalDate.toString()
    };
  }

  Task _mapToTask(Map<String, dynamic> map) {
    return Task(
      name: map["title"],
      finalDate: DateTime.parse(map["final_date"]),
      steps: []
    );
  }



}

class MockTaskRepository implements TaskRepository {

  static final shared = MockTaskRepository();


  List<Task> _taskList = [
    Task(
      name: "Дописать тз на стражировку",
      finalDate: DateTime.now().add(Duration(days: 1)),
      steps: [
        TaskStep("Написать часть про главный экран"),
        TaskStep("Очень сложный длинный шаг, на который легко наткнуться, сложно выполнить и невозможно забыть")
      ]
    ),
    Task(
        name: "Дорисовать дизайн",
        finalDate: DateTime.now().add(Duration(days: 1)),
        steps: []
    ),
  ];

  @override
  Future<List<Task>> getTaskList() {
    return Future.delayed(Duration(seconds: 2)).then((value) => _taskList);
  }

  @override
  Future<int> getCompletedTaskCount() {
    return Future.delayed(Duration(seconds: 2)).then((value) => _taskList.where((element) => element.isCompleted).length);
  }

  @override
  Future<List<Task>> getIncompletedListTask() {
    return Future.delayed(Duration(seconds: 2)).then((value) => _taskList.where((element) => !element.isCompleted).toList());
  }

  @override
  Future<int> getListCount() {
    return Future.delayed(Duration(seconds: 2)).then((value) => _taskList.length);
  }

  @override
  Future<int> saveTask(Task task) {
    // TODO: implement saveTask
    throw UnimplementedError();
  }

  @override
  Future<int> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }

}
