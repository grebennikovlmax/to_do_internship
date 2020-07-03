import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/model/task.dart';

abstract class TaskDetailPageState {

}

class LoadedPageState implements TaskDetailPageState {

  final CategoryTheme theme;
  final String title;
  final DateTime finalDate;
  final DateTime notificationDate;
  final String creationDate;
  final int taskId;
  final List<TaskStep> stepList;

  LoadedPageState(this.theme, this.title, this.finalDate, this.notificationDate, this.creationDate, this.taskId, this.stepList);

}