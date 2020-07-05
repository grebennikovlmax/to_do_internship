import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/model/task.dart';

abstract class TaskDetailPageState {

}

class LoadedPageState implements TaskDetailPageState {

  final int categoryId;
  final String title;
  final DateTime finalDate;
  final DateTime notificationDate;
  final String creationDate;
  final int taskId;
  final List<TaskStep> stepList;
  final bool isCompleted;

  LoadedPageState(this.categoryId, this.title, this.finalDate, this.notificationDate, this.creationDate, this.taskId, this.stepList, this.isCompleted);

}