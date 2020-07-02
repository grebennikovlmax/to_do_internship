import 'dart:async';

import 'package:intl/intl.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_state.dart';

class TaskCreationBloc {

  final _dateStateStreamController = StreamController<DateState>();
  final _dateEventStreamController = StreamController<DateEvent>();
  final dateFormatter = DateFormat("dd.MM.yyyy");
  final dateTimeFormatter = DateFormat("dd.MM.yyyy H:mm");

  Stream get dateStateStream => _dateStateStreamController.stream;

  Sink get dateEventSink => _dateEventStreamController.sink;

  String _finalDate = 'Дата выполнения';
  String _notificationDate = 'Напомнить';

  TaskCreationBloc() {
    _dateEventStreamController.stream.listen((event) {
      _setDateState(event);
    });
  }

  void _setDateState(DateEvent event) {
    if(event.finalDate != null) {
      _finalDate = dateFormatter.format(event.finalDate);
    }
    if(event.notificationDate != null) {
      _notificationDate = dateTimeFormatter.format(event.notificationDate);
    }
    _dateStateStreamController.add(DateState(_notificationDate, _finalDate));
   }

  void dispose() {
    _dateStateStreamController.close();
    _dateEventStreamController.close();
  }
}