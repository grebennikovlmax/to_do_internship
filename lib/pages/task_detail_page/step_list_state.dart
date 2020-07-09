import 'package:todointernship/model/task.dart';

abstract class StepListState {}

class LoadingStepListState implements StepListState {}

class LoadedStepListState implements StepListState {
  final List<TaskStep> stepList;
  final String creationDate;

  LoadedStepListState(this.creationDate, this.stepList);
}