import 'package:intl/intl.dart';

extension IsSameDate on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime daysBefore(int days) {
    return add(Duration(days: -days));
  }

  DateTime addMonths(int m) {
    int y = year;
    final times = (month + m) ~/ 12;
    final remaining = (month + m) % 12;
    if (times > 0) y += times;
    return DateTime(y, remaining, day);
  }

  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  int weekNumber() {
    int dayOfYear = int.parse(DateFormat("D").format(this));
    int woy = ((dayOfYear - weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(year - 1);
    } else if (woy > numOfWeeks(year)) {
      woy = 1;
    }
    return woy;
  }
}
