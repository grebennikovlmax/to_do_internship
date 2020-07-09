import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_state.dart';

class DatePickerBloc extends Bloc<DateEvent, DateState> {

  final _dateFormatter = DateFormat("dd.MM.yyyy");
  final _dateTimeFormatter = DateFormat("dd.MM.yyyy H:mm");
  String _finalDate;
  String _notificationDate;
  bool _finalDayIsExpired;
  bool _notificationDayIsExpired;

  DatePickerBloc({DateTime notificationDate, DateTime finalDate}) : super(null) {
    if (notificationDate != null) {
      _notificationDayIsExpired = notificationDate.isBefore(DateTime.now());
      _notificationDate = _dateTimeFormatter.format(notificationDate);
    }

    if (finalDate != null) {
      _finalDayIsExpired = finalDate.isBefore(DateTime.now());
      _finalDate = _dateFormatter.format(finalDate);
    }

    _finalDate ??= 'Дата выполнения';
    _notificationDate ??= 'Напомнить';
  }

  @override
  DateState get state => _initState();

  @override
  Stream<DateState> mapEventToState(DateEvent event) async* {
    yield* _setDateState(event);
  }

  Stream<DateState> _setDateState(DateEvent event) async* {
    if(event.finalDate != null) {
      _finalDayIsExpired = event.finalDate.isBefore(DateTime.now());
      _finalDate = _dateFormatter.format(event.finalDate);
    }
    if(event.notificationDate != null) {
      _notificationDayIsExpired = event.notificationDate.isBefore(DateTime.now());
      _notificationDate = _dateTimeFormatter.format(event.notificationDate);
    }
    yield _initState();
  }

  DateState _initState() {
    return DateState(_notificationDate, _finalDate, _finalDayIsExpired, _notificationDayIsExpired);
  }
  
}