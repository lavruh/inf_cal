import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inf_cal/domain/calendar_state.dart';
import 'package:inf_cal/domain/inf_cal_controller.dart';
import 'package:inf_cal/ui/widgets/drawer_menu.dart';
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
    return Scaffold(
      appBar: AppBar(),
      drawer: const DrawerMenu(),
      body: GetX<CalendarState>(builder: (state) {
        final calendarGroups = state.selectedCalendarGroups;
        controller.calendarGroups = calendarGroups;
        print(calendarGroups);
        return InfCal(
          controller: controller,
        );
      }),
    );
  }
}
