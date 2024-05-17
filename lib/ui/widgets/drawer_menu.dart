import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inf_cal/ui/widgets/calendar_select_widget.dart';
import 'package:inf_cal/utils/widgets/user_auth_widget.dart';
import 'package:inf_cal/domain/calendar_state.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const UserAuthWidget(),
            TextButton(
                onPressed: () => Get.find<CalendarState>().getCalendarGroups(),
                child: const Text("get Calendars")),
            const CalendarSelectWidget(),
          ],
        ),
      ),
    );
  }
}
