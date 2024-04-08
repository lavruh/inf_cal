import 'package:flutter/material.dart';
import 'package:inf_cal/domain/calendar_entry.dart';
import 'package:inf_cal/domain/calendar_group.dart';
import 'package:inf_cal/domain/inf_cal_controller.dart';
import 'package:inf_cal/ui/widgets/inf_cal.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final controller = InfCalController();

  @override
  Widget build(BuildContext context) {
    controller.calendarGroups = [
      CalendarGroup(200, title: "title", entries: [
        CalendarEntry(start: DateTime(2024, 4, 1, 5, 20), end: DateTime(2024, 6, 2, 12, 0), title: "title")
      ])
    ];
    return Scaffold(
        body: InfCal(
      controller: controller,
    ));
  }
}
