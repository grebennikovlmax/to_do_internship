extension PickDate on DateTime {

  static DateTime today() {
    final currentDate = DateTime.now();
    return  DateTime(currentDate.year,currentDate.month,currentDate.day,18);
  }

  static DateTime tomorrow() {
    final currentDate = DateTime.now();
    return DateTime(currentDate.year,currentDate.month,currentDate.day + 1,9);
  }

  static DateTime nextWeek() {
    final currentDate = DateTime.now();
    return DateTime(currentDate.year,currentDate.month,currentDate.day + 7,9);
  }
}