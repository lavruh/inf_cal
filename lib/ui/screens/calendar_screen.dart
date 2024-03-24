import 'package:flutter/material.dart';
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
    return Scaffold(
        body: InfCal(
          controller: controller,
        ));
  }
}
