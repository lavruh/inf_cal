import 'package:inf_cal/data/calendar_service.dart';
import 'package:inf_cal/domain/calendar_entry.dart';
import 'package:inf_cal/domain/calendar_group.dart';
import 'package:inf_cal/utils/color_extension.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:icalendar_parser/icalendar_parser.dart';

class LocalCalendarService implements CalendarService {
  final Directory localDir;

  LocalCalendarService(this.localDir) {
    ICalendar.registerField(field: 'COLOR');
    ICalendar.registerField(field: 'X-WR-CALNAME');
  }

  final fileExtension = ".ics";

  @override
  Future<List<String>> getCalendarList() async {
    final dir = localDir;
    List<String> calendarNames = [];
    await for (final f in dir.list()) {
      if ((f is File) && p.extension(f.path) == fileExtension) {
        final name = p.basenameWithoutExtension(f.path);
        calendarNames.add(name);
      }
    }
    return calendarNames;
  }

  @override
  createCalendar(CalendarGroup calendar) async {
    final dataString = _generateIcalString({
      "PRODID": "InfCalendar",
      "VERSION": 1.0,
      "CALSCALE": "GREGORIAN",
      "METHOD": "PUBLISH",
      "X-WR-CALNAME": calendar.title,
      "COLOR": calendar.color.toHex(),
    }, []);
    final f = File(p.join(localDir.path, "${calendar.id}$fileExtension"));
    await f.writeAsString(dataString);
  }

  @override
  updateEvent(String calendarId, CalendarEntry event) async {
    final id = event.id;
    final cal = await _getCalendar(calendarId);
    Map<String, dynamic> icalEvent = _calendarEntryToIcsEvent(event);
    final idx = cal.data.indexWhere((e) => e["uid"] == id);
    if (idx == -1) throw Exception("Event with id[$id] not found");
    cal.data.removeAt(idx);
    cal.data.insert(idx, icalEvent);
    final dataString = encodeIcalDataString(cal);
    final f = File(p.join(localDir.path, "$calendarId$fileExtension"));
    await f.writeAsString(dataString, flush: true);
  }

  @override
  Future<CalendarGroup> getCalendar(String calendarId) async {
    try {
      final cal = await _getCalendar(calendarId);
      return CalendarGroup(
        id: calendarId,
        title: cal.headData["x-wr-calname"],
        color: HexColor.fromHex(cal.headData["color"] ?? "#bcbcbc"),
        entries: [],
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CalendarEntry>> getCalendarEvents(String calendarId) async {
    final cal = await _getCalendar(calendarId);
    List<CalendarEntry> entries = [];
    for (final e in cal.data) {
      if (e["type"] != "VEVENT") continue;
      final start = _icsDateToDateTime(e["dtstart"] as IcsDateTime);
      final dtEnd = _icsDateToDateTime(e["dtend"] as IcsDateTime);
      DateTime? end = start?.add(const Duration(minutes: 30));
      if (dtEnd != null) end = dtEnd;
      if (start == null || end == null) continue;
      entries.add(CalendarEntry(
        id: e["uid"],
        title: e["summary"] ?? "",
        start: start,
        end: end,
      ));
    }
    return entries;
  }

  @override
  Future<void> createEvent(String calendarId, CalendarEntry event) async {
    final cal = await _getCalendar(calendarId);
    Map<String, dynamic> icalEvent = _calendarEntryToIcsEvent(event);
    cal.data.add(icalEvent);
    final dataString = encodeIcalDataString(cal);
    final f = File(p.join(localDir.path, "$calendarId$fileExtension"));
    await f.writeAsString(dataString, flush: true);
  }

  Future<ICalendar> _getCalendar(String calendarId) async {
    final file = File(p.join(localDir.path, "$calendarId$fileExtension"));
    if (!file.existsSync()) {
      throw Exception("File / calendar with id [$calendarId] does not exist");
    }
    try {
      final cal = ICalendar.fromString(await file.readAsString());
      return cal;
    } catch (_) {
      rethrow;
    }
  }

  String encodeIcalDataString(ICalendar cal) {
    return _generateIcalString(cal.headData, cal.data);
  }

  String _generateIcalString(
      Map<String, dynamic> header, List<Map<String, dynamic>> data) {
    String s = "BEGIN:VCALENDAR\n";
    for (final e in header.entries) {
      s += "${e.key.toUpperCase()}:${e.value}\n";
    }
    s += _generateCalendarDataString(data);
    s += "END:VCALENDAR\n";
    return s;
  }

  String _generateCalendarDataString(List<Map<String, dynamic>> d) {
    String s = '';
    for (final e in d) {
      final entryType = (e["type"] as String).toUpperCase();
      s += "BEGIN:$entryType\n";
      for (final field in e.entries) {
        String value = "";
        if (field.value.runtimeType == IcsDateTime) {
          final d = (field.value as IcsDateTime).toDateTime();
          if (d != null) value = _dateToIcsDate(d);
        } else if (field.value.runtimeType == IcsStatus) {
          final status = (field.value as IcsStatus).name;
          value = status.toUpperCase();
        } else if (field.value.runtimeType == IcsTransp) {
          final status = (field.value as IcsTransp).name;
          value = status.toUpperCase();
        } else {
          value = field.value.toString();
        }
        s += "${field.key.toUpperCase()}:$value\n";
      }
      s += "END:$entryType\n";
    }
    return s;
  }

  String _dateToIcsDate(DateTime d) {
    return DateFormat("yyyyMMddTHHmmss'Z'").format(d);
  }

  DateTime? _icsDateToDateTime(IcsDateTime ics) {
    final d = ics.toDateTime();
    return d?.toLocal();
  }

  Map<String, dynamic> _calendarEntryToIcsEvent(CalendarEntry event) {
    return {
      "type": "VEVENT",
      "dtstart": IcsDateTime(dt: _dateToIcsDate(event.start.toUtc())),
      "dtend": IcsDateTime(dt: _dateToIcsDate(event.end.toUtc())),
      "dtstamp": IcsDateTime(dt: _dateToIcsDate(event.start.toUtc())),
      "uid": event.id,
      "created": IcsDateTime(dt: _dateToIcsDate(event.start.toUtc())),
      "lastModified": IcsDateTime(dt: _dateToIcsDate(event.start.toUtc())),
      "sequence": 2,
      "status": IcsStatus.confirmed,
      "summary": event.title,
      "transp": IcsTransp.opaque,
    };
  }
}
