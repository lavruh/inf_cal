import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inf_cal/domain/calendar_state.dart';

class CalendarSelectWidget extends StatelessWidget {
  const CalendarSelectWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<CalendarState>(
      builder: (state) {
        return Column(
          children: state.calendarGroups
              .map((e) => ListTile(
                    leading: Checkbox(
                      value: state.isGroupSelected(e),
                      onChanged: (value) => state.toggleGroupSelection(e),
                    ),
                    title: Text(e.title),
                    trailing: CircleAvatar(
                      backgroundColor: e.color,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
