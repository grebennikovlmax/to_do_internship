import 'dart:async';

import 'package:intl/intl.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/fab_state.dart';
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
  final _fabPositionStreamController = StreamController<double>();
  final _fabStateStreamController = StreamController<FabState>();
  final _taskEditingStreamController = StreamController<TaskEvent>();
  final _titleStreamController = StreamController<String>();

  Stream get taskDetailPageStateStream => _taskDetailPageStateStreamController.stream;
  Stream get fabStateStream => _fabStateStreamController.stream;
  Stream get titleStream => _titleStreamController.stream;

  Sink get fabPositionSink => _fabPositionStreamController.sink;
  Sink get taskEditingSink => _taskEditingStreamController.sink;

  double _fabTop = 124;
  double _fabScale = 1;

  TaskDetailPageBloc(Task task, this.taskEventSink)
      : _task = task,
        _pref = SharedPrefManager()
  {
    _loadPage().then((value) => _taskDetailPageStateStreamController.add(value));
    _bindTaskEventListeners();
    _bindFabPositionListener();
    _setFabState();
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
    return LoadedPageState(theme,_task.name,_task.finalDate,_task.notificationDate, creationDate, _task.id, _task.steps);
  }

  Future<CategoryTheme> _getTheme() async {
    return await _pref.loadTheme(_task.categoryId);
  }

  void _bindFabPositionListener() {
    _fabPositionStreamController.stream.listen((event) {
      _setFabPosition(event);
    });
  }

  void _setFabPosition(double offset) {
    var appBarHeight = 128.0;
    var defaultTop = appBarHeight - 4.0;
    var scaleStart = 96.0;
    var scaleEnd = scaleStart / 2.0;
    _fabScale = 1.0;
    if (offset < defaultTop - scaleStart) {
      _fabScale = 1;
    } else if(offset < defaultTop - scaleEnd) {
      _fabScale = (defaultTop - scaleEnd - offset) / scaleEnd;
    } else {
      _fabScale = 0;
    }
    _fabTop = defaultTop - offset;
    _setFabState();
  }

  void _setFabState() {
    var state = FabState(_fabTop, _fabScale, _task.isCompleted);
    _fabStateStreamController.add(state);
  }

  void _updateTaskName(UpdateTaskNameEvent event) {
    _titleStreamController.add(event.name);
    _task.name = event.name;
    _taskRepository.updateTask(_task);
  }

  void _onCompletedTask() {
    _task.isCompleted = !_task.isCompleted;
    _taskRepository.updateTask(_task);
    _setFabState();
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
    _fabPositionStreamController.close();
    _fabStateStreamController.close();
    _taskEditingStreamController.close();
    _titleStreamController.close();
  }

}