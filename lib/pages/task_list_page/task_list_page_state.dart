import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/pages/task_list_page/hidden_task_state.dart';

abstract class TaskListPageState {

}

class LoadedPageState implements TaskListPageState {

  final CategoryTheme theme;
  final HiddenTaskState hiddenState;
  final String title;

  LoadedPageState({this.theme, this.hiddenState, this.title});
}