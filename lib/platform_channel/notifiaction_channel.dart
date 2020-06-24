import 'package:flutter/services.dart';
import 'dart:async';


class PlatformNotificationChannel {

  final platform =  MethodChannel('notifications');

  Future<void> setNotification() async {
    final currentDate = DateTime.now();
    final cutDat = DateTime(currentDate.year,currentDate.month,currentDate.day,currentDate.hour,currentDate.minute, currentDate.second + 10);
    final date = cutDat.millisecondsSinceEpoch / 1000;
    print(date);
    final String a = "hello";
    final int id = 45;
    final result = await platform.invokeMethod('setNotification', {'timeSince': date, 'title': a, 'id': id});
    print(result);
  }

}