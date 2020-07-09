import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/step_event.dart';
import 'package:todointernship/pages/task_detail_page/step_list_state.dart';

class StepsCardBloc extends Bloc<StepEvent, StepListState> {

  final TaskRepository _taskRepository;
  final Task _task;
  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');
  String _createdDay;
  List<TaskStep> _stepList;

  StepsCardBloc(this._taskRepository, this._task) : super(null)
  {
    _createdDay = _dateFormatter.format(_task.createdDate);
    _stepList = _task.steps;
  }

  @override
  StepListState get state => _initState();

  @override
  Stream<StepListState> mapEventToState(StepEvent event) async*{
    if(event is UpdateStepsEvent) {
      yield _initState();
    } else if (event is EditStepEvent) {
      yield* _updateStep(event);
    } else if (event is DeleteStepEvent) {
      yield* _removeStep(event.id);
    } else if (event is CompletedStepEvent) {
      yield* _onCompletedStep(event);
    } else if (event is AddStepEvent) {
      yield* _addStep();
    }
  }

  Stream<StepListState> _updateStep(EditStepEvent event)  async* {
    var step = _stepList.firstWhere((element) => element.id == event.id);
    if(event.newText != null && event.newText.isNotEmpty) {
      step.description = event.newText;
      _taskRepository.updateStep(step);
      step.isEditing = !step.isEditing;
    } else if(step.description == null) {
      yield* _removeStep(step.id);
      return;
    } else {
      step.isEditing = !step.isEditing;
    }
    yield _initState();
  }

  Stream<StepListState> _removeStep(int id) async* {
    await _taskRepository.removeStep(id);
    _stepList.removeWhere((element) => element.id == id);
    yield _initState();
  }

  Stream<StepListState> _onCompletedStep(CompletedStepEvent event) async* {
    var step = _stepList.firstWhere((element) => element.id == event.id);
    step.isCompleted = !step.isCompleted;
    _taskRepository.updateStep(step);
    yield _initState();
  }

  Stream<StepListState> _addStep() async* {
    var step = TaskStep();
    step.taskID = _task.id;
    step.id = await _taskRepository.saveStep(step);
    _stepList.add(step);
    yield _initState();
  }

  LoadedStepListState _initState() {
    return LoadedStepListState(_createdDay, _stepList);
  }

}