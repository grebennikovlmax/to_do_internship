import 'dart:async';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/data/theme_list_data.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_list_page/hidden_task_state.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_state.dart';
import 'package:todointernship/pages/task_list_page/hidden_task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list_state.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';

class TaskListPageBloc {

  final SharedPrefManager _pref;
  final int _categoryId;
  final String _title;
  final _taskRepository = TaskDatabaseRepository.shared;

  final _taskListPageStateStreamController = StreamController<TaskListPageState>();
  final _taskListStateStreamController = StreamController<TaskListState>();
  final _hideTaskEventStreamController = StreamController<HiddenTaskEvent>();
  final _hiddenTaskStateStreamController = StreamController<HiddenTaskState>();
  final _taskEventStreamController = StreamController<TaskEvent>();
  final _themeStreamController = StreamController<CategoryTheme>();
  final _pickedThemeStreamController = StreamController<int>();

  Stream get taskListPageStream => _taskListPageStateStreamController.stream;
  Stream get hiddenTaskStateStream => _hiddenTaskStateStreamController.stream;
  Stream get taskListStateStream => _taskListStateStreamController.stream;
  Stream get themeStream => _themeStreamController.stream;

  Sink get hideTaskEventSink => _hideTaskEventStreamController.sink;
  Sink get taskEventSink => _taskEventStreamController.sink;
  Sink get pickerThemeSink => _pickedThemeStreamController.sink;

  bool _isHidden;
  List<Task> _taskList = [];

  TaskListPageBloc(int categoryId, String title)
      : _pref = SharedPrefManager(),
        _categoryId = categoryId,
        _title = title
  {
    _loadPage().then((value) => _taskListPageStateStreamController.add(value));
    _loadTaskList().then((_) => _setTaskListState());
    _bindHiddenEventListener();
    _bindTaskEventListener();
    _bindThemePicker();
  }

  Future<LoadedPageState> _loadPage() async {
    var theme = await _getTheme();
    _isHidden = await _getHiddenFlag();
    return LoadedPageState(theme: theme, title: _title, hiddenState: HiddenTaskState(_isHidden));
  }

  _bindHiddenEventListener() {
    _hideTaskEventStreamController.stream.listen((event) {
      _isHidden = !_isHidden;
      _saveHiddenFlag();
      _hiddenTaskStateStreamController.add(HiddenTaskState(_isHidden));
      _setTaskListState();
    });
  }

  _bindTaskEventListener() {
    _taskEventStreamController.stream.listen((event) { 
      switch(event.runtimeType) {
        case NewTaskEvent:
          _saveNewTask(event);
          break;
        case CompletedTaskEvent:
          _completeTask(event);
          break;
        case RemoveCompletedEvent:
          _removerCompleted();
          break;
        case RemoveTaskEvent:
          _removeTask(event);
          break;
        case UpdateTaskListEvent:
          _setTaskListState();
          break;
      }
    });
  }

  _bindThemePicker() {
    _pickedThemeStreamController.stream.listen((event) {
      _changeTheme(event);
    });
  }

  Future<void> _loadTaskList() async {
    _taskList = await _taskRepository.getTaskListForCategory(_categoryId);
  }

  void _setTaskListState() {
    if(_taskList.isEmpty) {
      _taskListStateStreamController.add(EmptyListState('На данный момент в этой ветке нет задач'));
    } else if(_isHidden) {
      var taskList = _taskList.where((element) => !element.isCompleted).toList();
      if(taskList.isEmpty && _taskList.isNotEmpty) {
        _taskListStateStreamController.add(EmptyListState('Все задания выполнены'));
      } else {
        _taskListStateStreamController.add(FullTaskListState(taskList));
      }
    } else {
      _taskListStateStreamController.add(FullTaskListState(_taskList));
    }
  }

  Future<void> _saveNewTask(NewTaskEvent event) async {
    var task = Task(
      categoryId: _categoryId,
      finalDate: event.finalDate,
      notificationDate: event.notificationDate,
      name: event.name
    );
    var id = await _taskRepository.saveTask(task);
    task.id = id;
    if(event.notificationDate != null) {
      var nm = PlatformNotificationChannel();
      nm.setNotification(task);
    }
    _taskList.add(task);
    _setTaskListState();
  }

  void _completeTask(CompletedTaskEvent event) {
    var task = _taskList.firstWhere((element) => element.id == event.taskId);
    task.isCompleted = !task.isCompleted;
    _setTaskListState();
    _taskRepository.updateTask(task);
  }

  void _removerCompleted() {
    _taskList.removeWhere((element) => element.isCompleted);
    _setTaskListState();
    _taskRepository.removeCompletedTask();
  }

  void _removeTask(RemoveTaskEvent event) {
    var id = event.taskId;
    _taskList.removeWhere((element) => element.id == id);
    _taskRepository.removeTask(id);
    _setTaskListState();
  }

  Future<CategoryTheme> _getTheme() async {
    return await _pref.loadTheme(_categoryId);
  }

  Future<void> _changeTheme(int color) async {
    var theme = ThemeListData.all.themes.firstWhere((element) => element.primaryColor == color);
    _themeStreamController.add(theme);
    await _pref.saveTheme(theme, _categoryId);
  }

  Future<bool> _getHiddenFlag() async {
    return await _pref.getHiddenFlag(_categoryId);
  }

  Future<void> _saveHiddenFlag() async {
    return await _pref.saveHiddenFlag(_isHidden, _categoryId);
  }

  void dispose() {
    _taskListPageStateStreamController.close();
    _hideTaskEventStreamController.close();
    _hiddenTaskStateStreamController.close();
    _taskListStateStreamController.close();
    _taskEventStreamController.close();
    _themeStreamController.close();
    _pickedThemeStreamController.close();
  }

}