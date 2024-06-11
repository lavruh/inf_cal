import 'package:inf_cal/domain/calendar_entry.dart';
import 'package:inf_cal/domain/calendar_group.dart';

abstract class CalendarService {
  Future<List<String>> getCalendarList();
  Future<CalendarGroup> getCalendar(String calendarId);
  Future<List<CalendarEntry>> getCalendarEvents(String calendarId);
  createCalendar(CalendarGroup calendar);
  Future<void> createEvent(String calendarId, CalendarEntry event);
  Future<void> updateEvent(String calendarId, CalendarEntry event);
}
