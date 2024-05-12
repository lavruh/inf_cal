import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inf_cal/data/calendar_repo.dart';
import 'package:inf_cal/domain/calendar_user.dart';
import 'package:inf_cal/domain/calendars_state.dart';
import 'package:inf_cal/ui/screens/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(CalendarUser.instance);
  final calendarState = Get.put(CalendarState(CalendarRepo()));
  calendarState.getCalendarGroups();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CalendarScreen(),
    );
  }
}
