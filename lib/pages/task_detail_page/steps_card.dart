import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/step_event.dart';
import 'package:todointernship/pages/task_detail_page/step_item.dart';
import 'package:todointernship/pages/task_detail_page/step_list_state.dart';
import 'package:todointernship/pages/task_detail_page/steps_card_bloc.dart';

class StepsCard extends StatefulWidget {

  final Task task;

  StepsCard(this.task);

  @override
  _StepsCardState createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard> {

  StepsCardBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var injector = Injector.appInstance;
    _bloc = StepsCardBloc(
        injector.getDependency<TaskRepository>(),
        widget.task,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, pageState) {
        var state = pageState as LoadedStepListState;
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text("Создано: ${state.creationDate}",
                  style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 0.6)
                  ),
                ),
              ),
              ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.stepList.length,
                      itemBuilder: (context, index) {
                        return StepItem(
                          onCompleted: () => _onCompleted(state.stepList[index].id),
                          onDelete: () => _onDelete(state.stepList[index].id),
                          onTextEditing: ([text]) => _updateStep(text, state.stepList[index].id),
                          step: state.stepList[index],
                        );
                      }
              ),
              ListTile(
                leading: Icon(Icons.add,
                    color: const Color(0xff1A9FFF)
                ),
                title: Text("Добавить шаг",
                  style: TextStyle(
                      color: const Color(0xff1A9FFF)
                  ),
                ),
                onTap: () => _bloc.add(AddStepEvent()),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: Divider(
                  thickness: 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                child: Text("Заметки по задаче..."),
              )
            ]
        );
      }
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _onDelete(int id) {
    _bloc.add(DeleteStepEvent(id));
  }

  void _updateStep(String text, int id) {
    _bloc.add(EditStepEvent(text,id));
  }

  void _onCompleted(int id) {
    _bloc.add(CompletedStepEvent(id));
  }
}