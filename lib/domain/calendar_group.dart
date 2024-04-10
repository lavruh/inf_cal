import 'package:flutter/material.dart';
import 'package:inf_cal/domain/calendar_entry.dart';

class CalendarGroup {
  final String title;
  final List<CalendarEntry> entries;
  final Color color;

  CalendarGroup({required this.title, required this.entries, Color? color})
      : color = color ?? Colors.green;
}
