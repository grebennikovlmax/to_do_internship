import 'dart:async';

import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/step_event.dart';

class StepsCardBloc {

  final _taskRepository = TaskDatabaseRepository.shared;

  final _stepEventStreamController = StreamController<StepEvent>();
  final _taskStepListStreamController = StreamController<List<TaskStep>>();

  Sink get stepEventSink => _stepEventStreamController.sink;

  Stream get taskStepListStream => _taskStepListStreamController.stream;

  List<TaskStep> _stepList;
  final int taskId;

  StepsCardBloc(this._stepList, this.taskId) {
    _updateStepList();
    _bindStepEventListeners();
  }

  void _bindStepEventListeners() {
    _stepEventStreamController.stream.listen((event) {
      switch(event.runtimeType) {
        case AddStepEvent:
          _addStep();
          break;
        case DeleteStepEvent:
          _deleteStep((event as DeleteStepEvent).id);
          break;
        case EditStepEvent:
          _updateStep(event);
          break;
        case CompletedStepEvent:
          _onCompletedStep(event);
      }
    });
  }

  void _updateStepList() {
    _taskStepListStreamController.add(_stepList);
  }

  Future<void> _addStep() async {
    var step = TaskStep();
    step.taskID = taskId;
    step.id = await _taskRepository.saveStep(step);
    _stepList.add(step);
    _updateStepList();
  }

  Future<void> _deleteStep(int id) async {
    await _taskRepository.removeStep(id);
    _stepList.removeWhere((element) => element.id == id);
    _updateStepList();
  }

  void _updateStep(EditStepEvent event) {
    var step = _stepList.firstWhere((element) => element.id == event.id);
    if(event.newText != null && event.newText.isNotEmpty) {
      step.description = event.newText;
      _taskRepository.updateStep(step);
      step.isEditing = !step.isEditing;
      _updateStepList();
    } else if(step.description == null) {
      _deleteStep(step.id);
    } else {
      step.isEditing = !step.isEditing;
      _updateStepList();
    }
  }

  void _onCompletedStep(CompletedStepEvent event) {
    var step = _stepList.firstWhere((element) => element.id == event.id);
    step.isCompleted = !step.isCompleted;
    _taskRepository.updateStep(step);
    _updateStepList();
  }

  void dispose() {
    _stepEventStreamController.close();
    _taskStepListStreamController.close();
  }
}