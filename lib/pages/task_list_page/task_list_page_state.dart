import 'package:todointernship/pages/task_list_page/hidden_task_state.dart';

abstract class TaskListPageState {}

class LoadedPageState implements TaskListPageState {

  final int categoryId;
  final HiddenTaskState hiddenState;
  final String title;

  LoadedPageState({this.categoryId, this.hiddenState, this.title});
}