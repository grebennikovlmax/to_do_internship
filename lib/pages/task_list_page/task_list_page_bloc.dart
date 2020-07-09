import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_state.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';

class TaskListPageBloc extends Bloc<TaskEvent, TaskListPageState> {

  final TaskRepository _taskRepository;
  final SharedPrefManager _prefManager;
  final PlatformNotificationChannel _platformNotificationChannel;
  final int _categoryId;
  final String _title;
  bool _isHidden;
  List<Task> _taskList;

  TaskListPageBloc(
      this._taskRepository,
      this._prefManager,
      this._platformNotificationChannel,
      this._title,
      this._categoryId)
        : super(LoadingTaskListPageState())
  {
    _loadPage().then((value) => this.add(UpdateTaskListEvent()));
  }

  @override
  Stream<TaskListPageState> mapEventToState(TaskEvent event) async* {
    if( event is NewTaskEvent) {
      yield* _saveTask(event);
    } else if (event is CompletedTaskEvent) {
      yield* _completeTask(event);
    } else if (event is RemoveCompletedEvent) {
      yield* _removeCompleted();
    } else if (event is RemoveTaskEvent) {
      yield* _removeTask(event);
    } else if (event is UpdateTaskListEvent) {
      yield* _setTaskListState();
    } else if (event is HideTaskEvent) {
      yield* _hideTaskEvent();
    }
  }

  Future<void> _loadPage() async {
    _taskList = await _taskRepository.getTaskListForCategory(_categoryId);
    _isHidden = await _getHiddenFlag();
  }

  Stream<TaskListPageState> _saveTask(NewTaskEvent event) async* {
    var task = Task(
        categoryId: _categoryId,
        finalDate: event.finalDate,
        notificationDate: event.notificationDate,
        name: event.name
    );
    var id = await _taskRepository.saveTask(task);
    task.id = id;
    if(event.notificationDate != null) {
      _platformNotificationChannel.setNotification(task);
    }
    _taskList.add(task);
    yield* _setTaskListState();
  }

  Stream<TaskListPageState> _completeTask(CompletedTaskEvent event) async* {
    var task = _taskList.firstWhere((element) => element.id == event.taskId);
    task.isCompleted = !task.isCompleted;
    _taskRepository.updateTask(task);
    yield* _setTaskListState();
  }

  Stream<TaskListPageState> _removeCompleted() async* {
    _taskList.removeWhere((element) => element.isCompleted);
    _taskRepository.removeCompletedTask();
    yield* _setTaskListState();
  }

  Stream<TaskListPageState> _removeTask(RemoveTaskEvent event) async* {
    var id = event.taskId;
    _taskList.removeWhere((element) => element.id == id);
    _taskRepository.removeTask(id);
    yield* _setTaskListState();
  }

  Stream<TaskListPageState> _setTaskListState() async* {
    var taskList = _taskList;
    if(_taskList.isEmpty) {
      yield EmptyTaskListPageState(_isHidden, _categoryId, _title, 'На данный момент в этой ветке нет задач');
      return;
    } else if(_isHidden) {
      taskList = _taskList.where((element) => !element.isCompleted).toList();
      if(taskList.isEmpty && _taskList.isNotEmpty) {
        yield EmptyTaskListPageState(_isHidden, _categoryId, _title, 'Все задания выполнены');
        return;
      }
    }
    yield NotEmptyTaskListPageState(_isHidden, _categoryId, _title, taskList);
  }

  Stream<TaskListPageState> _hideTaskEvent() async* {
    _isHidden = !_isHidden;
    _saveHiddenFlag();
    yield* _setTaskListState();
  }

  Future<bool> _getHiddenFlag() async {
    return await _prefManager.getHiddenFlag(_categoryId);
  }

  Future<void> _saveHiddenFlag() async {
    return await _prefManager.saveHiddenFlag(_isHidden, _categoryId);
  }

}