import 'package:flutter/services.dart';
import 'dart:async';

import 'package:todointernship/model/task.dart';


class PlatformNotificationChannel {

  final platform =  MethodChannel('notifications');

  Future<int> setNotification(Task task) async {
    final arg = {
      'timeSince': task.notificationDate.millisecondsSinceEpoch,
      'title': task.name,
      'id': task.id
    };
    final res = await platform.invokeMethod('setNotification', arg);
    return res;
  }

}