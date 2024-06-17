import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inf_cal/data/calendar_service.dart';
import 'package:inf_cal/data/google_calendar_service.dart';
import 'package:inf_cal/data/local_calendar_service.dart';
import 'package:inf_cal/domain/calendar_entry.dart';
import 'package:inf_cal/domain/calendar_group.dart';
import 'package:inf_cal/domain/calendar_user.dart';

class CalendarRepo extends ChangeNotifier {
  CalendarRepo() {
    calendarUser.addListener(() => selectService());
    selectService();
  }
  final calendarUser = Get.find<CalendarUser>();
  late CalendarService service;

  selectService() async {
    final httpClient = calendarUser.httpClient;
    if (httpClient != null) {
      service = GoogleCalendarService(httpClient);
    } else {
      final dir = await _getAppDataDirectory();
      service = LocalCalendarService(dir);
      dir.watch().listen((onData) {
        if (onData.runtimeType != FileSystemModifyEvent) {
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  Future<Directory> _getAppDataDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, "inf_calendar"));
    if (!dir.existsSync()) {
      dir.createSync();
    }
    return dir;
  }

  Future<List<CalendarGroup>> getCalendars() async {
    final calendars = <CalendarGroup>[];
    try {
      final calendarIds = await service.getCalendarList();
      for (final calendarId in calendarIds) {
        final calendar = await service.getCalendar(calendarId);
        calendars.add(calendar);
      }
    } catch (e) {
      Get.snackbar("Error", "Cannot get calendar $e");
    }
    return calendars;
  }

  Future<List<CalendarEntry>> getCalendarEvents(String id) async {
    final entries = await service.getCalendarEvents(id);
    List<CalendarEntry> calendarEntries = [];
    for (final entry in entries) {
      try {
        calendarEntries.add(entry);
      } on Exception {
        continue;
      }
    }
    return calendarEntries;
  }

  updateEvent({
    required String calendarId,
    required CalendarEntry event,
  }) async {
    await service.updateEvent(calendarId, event);
  }

  createEvent({
    required String calendarId,
    required CalendarEntry event,
  }) async {
    await service.createEvent(calendarId, event);
  }

  createCalendar({required CalendarGroup calendar}) {
    service.createCalendar(calendar);
  }
}
