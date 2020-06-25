import 'package:sqflite/sqflite.dart';
import 'package:todointernship/model/task.dart';


abstract class TaskRepository {
  Future<List<Task>> getTaskList();
  Future<List<Task>> getIncompletedListTask();
  Future<int> saveTask(Task task);
  Future<int> updateTask(Task task);
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
