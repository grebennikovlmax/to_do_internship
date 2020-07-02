import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/task_image.dart';
import 'package:todointernship/pages/task_detail_page/photo_list.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_block.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_state.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_picker_bloc.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_state.dart';
import 'package:todointernship/pages/task_detail_page/steps_card.dart';
import 'package:todointernship/pages/task_detail_page/fab_state.dart';
import 'package:todointernship/widgets/task_creation_dialog/task_creation_dialog.dart';

class TaskDetailBlocProvider extends InheritedWidget {

  final TaskDetailPageBloc bloc;

  static TaskDetailBlocProvider of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskDetailBlocProvider>();

  TaskDetailBlocProvider({this.bloc, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

}

class TaskDetailPage extends StatefulWidget {

  final TaskDetailPageBloc bloc;

  TaskDetailPage(this.bloc);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {

  @override
  Widget build(BuildContext context) {
    return TaskDetailBlocProvider(
        bloc: widget.bloc,
        child: StreamBuilder<TaskDetailPageState>(
            stream: widget.bloc.taskDetailPageStateStream,
            builder: (context, snapshot) {
              if(snapshot.data is LoadedPageState) {
                return _StepList(state: snapshot.data);
              }
              return Container();
            }
        )
    );
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

class _StepList extends StatefulWidget {

  final LoadedPageState state;

  _StepList({this.state});

  @override
  State<StatefulWidget> createState() {
    return _StepListState();
  }


}

class _StepListState extends State<_StepList> {

  final double _appBarHeight = 128;
  TaskDetailPageBloc _taskDetailBloc;
  ScrollController _scrollController;
  DatePickerBloc _datePickerBloc;

  @override
  void initState() {
    super.initState();
    _datePickerBloc = DatePickerBloc(
        finalDate: widget.state.finalDate,
        notificationDate: widget.state.notificationDate
    );
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskDetailBloc = TaskDetailBlocProvider.of(context).bloc;
    _scrollController.addListener(() {
      _taskDetailBloc.fabPositionSink.add(_scrollController.offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.state.theme.backgroundColor),
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              StreamBuilder<String>(
                stream: _taskDetailBloc.titleStream,
                initialData: widget.state.title,
                builder: (context, snapshot) {
                    return _TaskDetailSliverAppBar(
                      title: snapshot.data,
                      color: Color(widget.state.theme.primaryColor),
                      onSelected: _onSelectedMenuItem,
                      height: _appBarHeight,
                    );
                  }
              ),
              _TaskDetailPageBody(
                taskDetailBloc: _taskDetailBloc,
                datePickerBloc: _datePickerBloc,
              )
            ]
          ),
          StreamBuilder<FabState>(
            stream: TaskDetailBlocProvider.of(context).bloc.fabStateStream,
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Container();
              return Positioned(
                top: snapshot.data.top,
                left: 16,
                child: Transform(
                  transform: Matrix4.identity()
                    ..scale(snapshot.data.scale),
                  alignment: Alignment.center,
                  child: FloatingActionButton(
                    onPressed: _onCompleted,
                    child: Icon(snapshot.data.isCompleted ? Icons.clear : Icons.check),
                  ),
                ),
              );
            }
          )
        ]
      )
    );
  }

  @override
  void dispose() {
    _datePickerBloc.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectedMenuItem(_TaskDetailPopupMenuItem item) {
    switch(item) {
      case _TaskDetailPopupMenuItem.update:
        _updateTask();
        break;
      case _TaskDetailPopupMenuItem.delete:
        _deleteTask();
    }
  }

  Future<void> _updateTask() async {
    await showDialog(
        context: context,
        builder: (context) {
          return TaskCreationDialog(
            edit: true,
            creationEventSink: _taskDetailBloc.taskEditingSink,
          );
        }
    );
  }

  void _deleteTask() {
    _taskDetailBloc.taskEditingSink.add(RemoveTaskEvent());
    Navigator.of(context).pop();
  }

  void _onCompleted() {
    _taskDetailBloc.taskEditingSink.add(CompletedTaskEvent());
  }

}

class _TaskDetailPageBody extends StatelessWidget {

  final TaskDetailPageBloc taskDetailBloc;
  final DatePickerBloc datePickerBloc;

  _TaskDetailPageBody({this.taskDetailBloc, this.datePickerBloc});
  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
          Card(
            margin: EdgeInsets.fromLTRB(16, 28, 16, 10),
            child: StreamBuilder<List<TaskStep>>(
                stream: taskDetailBloc.taskStepListStream,
                builder: (context, snapshot) {
                  if(!snapshot.hasData) return Container();
                  return StepsCard(stepList: snapshot.data);
                }
            ),
          ),
          StreamBuilder<DateState>(
            stream: datePickerBloc.dateStateStream,
            builder: (context, snapshot) {
              return _DateNotificationCard(
                onPickDate: () {},
                state: snapshot.data,
                onNotification: () {},
              );
            },
          ),
          SizedBox(height: 30),
          StreamBuilder<List<TaskImage>>(
              stream: taskDetailBloc.imageListStream,
              builder: (context, snapshot) {
                if(!snapshot.hasData) return Container();
                return PhotoList(
                  onDelete: (val) {} ,
                  imageList: snapshot.data,
                  onPickPhoto: () {},
                );
              }
          )
        ]
      )
    );
  }
}


enum _TaskDetailPopupMenuItem {update, delete}

class _TaskDetailSliverAppBar extends StatelessWidget {

  final double height;
  final String title;
  final Color color;
  final PopupMenuItemSelected<_TaskDetailPopupMenuItem> onSelected;

  _TaskDetailSliverAppBar({this.height, this.title, this.onSelected, this.color});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: color,
      pinned: true,
      expandedHeight: height,
      flexibleSpace: FlexibleSpaceBar(
          title: Text(title)
      ),
      actions: <Widget>[
        PopupMenuButton<_TaskDetailPopupMenuItem>(
          onSelected: onSelected,
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<_TaskDetailPopupMenuItem>(
                value: _TaskDetailPopupMenuItem.delete,
                child: Text('Удалить'),
              ),
              PopupMenuItem<_TaskDetailPopupMenuItem>(
                value: _TaskDetailPopupMenuItem.update,
                child: Text('Редактировать'),
              )
            ];
          },
        )
      ],
    );
  }
}

class _DateNotificationCard extends StatelessWidget {

  final VoidCallback onPickDate;
  final DateState state;
  final VoidCallback onNotification;

  _DateNotificationCard({this.onPickDate, this.onNotification, this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16, 10, 16, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              onTap: onNotification,
              leading: Icon(Icons.notifications_none),
              title: state == null ? Text('Напомнить') : Text(state.notificationDate)
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 2,
            ),
          ),
          ListTile(
            leading: Icon(Icons.insert_invitation),
            onTap: onPickDate,
            title: state == null ? Text('Добавить дату выполнения')
                : Text(state.finalDate),
          )
        ],
      ),
    );
  }
}


