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
      CalendarGroup(
        title: "title",
        entries: [
          CalendarEntry(
              start: DateTime(2024, 4, 1, 5, 20),
              end: DateTime(2024, 6, 2, 12, 0),
              title: "title")
        ],
      ),
      CalendarGroup(
        title: "Group2",
        color: Colors.deepOrangeAccent,
        entries: [
          CalendarEntry(
              start: DateTime(2024, 4, 6, 12, 30),
              end: DateTime(2024, 4, 10, 20, 0),
              title: "t1"),
          CalendarEntry(
              start: DateTime(2024, 4, 11, 0, 30),
              end: DateTime(2024, 8, 10, 20, 0),
              title: "t1"),
        ],
      )
    ];
    return Scaffold(
        body: InfCal(
      controller: controller,
    ));
  }
}
