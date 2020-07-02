import 'package:todointernship/model/category_theme.dart';

abstract class TaskDetailPageState {

}

class LoadedPageState implements TaskDetailPageState {

  final CategoryTheme theme;
  final String title;
  final DateTime finalDate;
  final DateTime notificationDate;

  LoadedPageState(this.theme, this.title, this.finalDate, this.notificationDate);

}