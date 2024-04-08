import 'package:inf_cal/domain/calendar_entry.dart';

class CalendarGroup {
  final String title;
  final List<CalendarEntry> entries;
  final double offset;

  CalendarGroup(this.offset, {required this.title, required this.entries});
}
