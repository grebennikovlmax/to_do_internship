import 'dart:async';

import 'package:intl/intl.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_state.dart';

class DatePickerBloc {

  final _dateStateStreamController = StreamController<DateState>();
  final _dateEventStreamController = StreamController<DateEvent>();
  final dateFormatter = DateFormat("dd.MM.yyyy");
  final dateTimeFormatter = DateFormat("dd.MM.yyyy H:mm");

  Stream get dateStateStream => _dateStateStreamController.stream;

  Sink get dateEventSink => _dateEventStreamController.sink;

  String _finalDate;
  String _notificationDate;
  bool _finalDayIsExpired;
  bool _notificationDayIsExpired;

  DatePickerBloc({DateTime finalDate,DateTime notificationDate}) {
    _finalDate = finalDate != null ? dateFormatter.format(finalDate) : 'Дата выполнения';
    _notificationDate = notificationDate != null ? dateTimeFormatter.format(notificationDate) : 'Напомнить';
    _setDateState(finalDate, notificationDate);
    _dateEventStreamController.stream.listen((event) {
      _setDateState(event.finalDate, event.notificationDate);
    });
  }

  void _setDateState(DateTime finalDate, DateTime notificationDate) {
    if(finalDate != null) {
      _finalDayIsExpired = finalDate.isBefore(DateTime.now());
      _finalDate = dateFormatter.format(finalDate);
    }
    if(notificationDate != null) {
      _notificationDayIsExpired = notificationDate.isBefore(DateTime.now());
      _notificationDate = dateTimeFormatter.format(notificationDate);
    }
    _dateStateStreamController.add(DateState(_notificationDate, _finalDate, _finalDayIsExpired, _notificationDayIsExpired));
   }

  void dispose() {
    _dateStateStreamController.close();
    _dateEventStreamController.close();
  }
}