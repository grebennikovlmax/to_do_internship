abstract class StepEvent {}

class AddStepEvent implements StepEvent {}

class EditStepEvent implements StepEvent {

  final String newText;
  final int id;

  EditStepEvent(this.newText, this.id);

}

class DeleteStepEvent implements StepEvent {

  final int id;

  DeleteStepEvent(this.id);
}

class CompletedStepEvent implements StepEvent {

  final int id;

  CompletedStepEvent(this.id);
}