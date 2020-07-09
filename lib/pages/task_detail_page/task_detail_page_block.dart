import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_state.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';

class TaskDetailPageBloc extends Bloc<TaskEvent, TaskDetailPageState> {

  final Task _task;
  final TaskRepository _taskRepository;
  final PlatformNotificationChannel _platformNotificationChannel;
  final Sink<TaskEvent> _taskSink;

  TaskDetailPageBloc(this._task, this._taskRepository, this._platformNotificationChannel, this._taskSink) : super(null);

  @override
  TaskDetailPageState get state => _initState();

  @override
  Stream<TaskDetailPageState> mapEventToState(TaskEvent event) async* {
    if (event is UpdateTaskNameEvent) {
      yield* _updateTaskName(event);
    } else if (event is RemoveTaskEvent) {
      _removeTask();
    } else if (event is CompletedTaskEvent) {
      _onCompletedTask();
    } else if (event is UpdateTaskFinalDateEvent) {
      _onUpdateFinalDate(event);
    } else if (event is UpdateTaskNotificationDateEvent) {
      _onUpdateNotificationDate(event);
    }
  }

  Stream<TaskDetailPageState> _updateTaskName(UpdateTaskNameEvent event) async* {
    _task.name = event.name;
    yield _initState();
  }

  void _removeTask() {
    _taskSink.add(RemoveTaskEvent(_task.id));
  }

  void _onCompletedTask() {
    _task.isCompleted = !_task.isCompleted;
    _taskRepository.updateTask(_task);
  }

  void _onUpdateFinalDate(UpdateTaskFinalDateEvent event) {
    _task.finalDate = event.newDate;
    _taskRepository.updateTask(_task);
  }

  void _onUpdateNotificationDate(UpdateTaskNotificationDateEvent event) {
    _task.notificationDate = event.newDate;
    _taskRepository.updateTask(_task);
    _platformNotificationChannel.setNotification(_task);
  }

  LoadedTaskDetailPageState _initState() {
    return LoadedTaskDetailPageState(_task);
  }

}