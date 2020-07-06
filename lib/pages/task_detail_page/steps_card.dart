import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/step_event.dart';
import 'package:todointernship/pages/task_detail_page/step_item.dart';
import 'package:todointernship/pages/task_detail_page/steps_card_bloc.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page.dart';

class StepsCard extends StatefulWidget {

  final String creationDate;

  StepsCard({this.creationDate});

  @override
  _StepsCardState createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard> {

  StepsCardBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = StepsCardBloc(
        TaskDetailBlocProvider.of(context).stepList,
        TaskDetailBlocProvider.of(context).taskId
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text("Создано: ${widget.creationDate}",
              style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.6)
              ),
            ),
          ),
          StreamBuilder<List<TaskStep>>(
            stream: _bloc.taskStepListStream,
            initialData: TaskDetailBlocProvider.of(context).stepList,
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Container();
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return StepItem(
                      onCompleted: () => _onCompleted(snapshot.data[index].id),
                      onDelete: () => _onDelete(snapshot.data[index].id),
                      onTextEditing: ([text]) => _updateStep(text, snapshot.data[index].id),
                      step: snapshot.data[index],
                    );
                  }
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
            onTap: () => _bloc.stepEventSink.add(AddStepEvent()),
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

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  void _onDelete(int id) {
    _bloc.stepEventSink.add(DeleteStepEvent(id));
  }

  void _updateStep(String text, int id) {
    _bloc.stepEventSink.add(EditStepEvent(text,id));
  }

  void _onCompleted(int id) {
    _bloc.stepEventSink.add(CompletedStepEvent(id));
  }
}