import 'dart:async';

import 'package:intl/intl.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_state.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';

class TaskDetailPageBloc {

  final Task _task;
  final _pref;
  final Sink<TaskEvent> taskEventSink;

  final _taskRepository = TaskDatabaseRepository.shared;
  final _taskDetailPageStateStreamController = StreamController<TaskDetailPageState>();
  final _taskEditingStreamController = StreamController<TaskEvent>();
  final _titleStreamController = StreamController<String>();

  Stream get taskDetailPageStateStream => _taskDetailPageStateStreamController.stream;
  Stream get titleStream => _titleStreamController.stream;

  Sink get taskEditingSink => _taskEditingStreamController.sink;

  TaskDetailPageBloc(Task task, this.taskEventSink)
      : _task = task,
        _pref = SharedPrefManager()
  {
    _loadPage().then((value) => _taskDetailPageStateStreamController.add(value));
    _bindTaskEventListeners();
  }

  void _bindTaskEventListeners() {
    _taskEditingStreamController.stream.listen((event) {
      switch(event.runtimeType) {
        case UpdateTaskNameEvent:
          _updateTaskName(event);
          break;
        case RemoveTaskEvent:
          taskEventSink.add(RemoveTaskEvent(_task.id));
          break;
        case CompletedTaskEvent:
          _onCompletedTask();
          break;
        case UpdateTaskNotificationDateEvent:
          _onUpdateNotificationDate(event);
          break;
        case UpdateTaskFinalDateEvent:
          _onUpdateFinalDate(event);
          break;
      }
    });
  }

  Future<LoadedPageState> _loadPage() async{
    var theme = await _getTheme();
    var dateFormatter = DateFormat("dd.MM.yyyy");
    var creationDate = dateFormatter.format(_task.createdDate);
    return LoadedPageState(theme,_task.name,_task.finalDate,_task.notificationDate, creationDate, _task.id, _task.steps, _task.isCompleted);
  }

  Future<CategoryTheme> _getTheme() async {
    return await _pref.loadTheme(_task.categoryId);
  }

  void _updateTaskName(UpdateTaskNameEvent event) {
    _titleStreamController.add(event.name);
    _task.name = event.name;
    _taskRepository.updateTask(_task);
  }

  void _onCompletedTask() {
    _task.isCompleted = !_task.isCompleted;
    _taskRepository.updateTask(_task);
  }

  void _onUpdateNotificationDate(UpdateTaskNotificationDateEvent event) {
    _task.notificationDate = event.newDate;
    _taskRepository.updateTask(_task);
    var pm = PlatformNotificationChannel();
    pm.setNotification(_task);
  }

  void _onUpdateFinalDate(UpdateTaskFinalDateEvent event) {
    _task.finalDate = event.newDate;
    _taskRepository.updateTask(_task);
  }

  void dispose() {
    _taskDetailPageStateStreamController.close();
    _taskEditingStreamController.close();
    _titleStreamController.close();
  }

}