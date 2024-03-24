
import 'package:flutter/material.dart';
import 'package:inf_cal/utils/date_extension.dart';
import 'package:intl/intl.dart';

class InfCalController extends ChangeNotifier {
  double dayEntryHeight = 50.0;
  double widgetWidth = 100.0;
  double scroll = 0.0;
  List<Widget> viewBuffer = [];
  int datesPerScreen = 0;
  DateTime? dateStartView;
  DateTime? dateEndView;
  DateTime currentDate = DateTime.now();
  double scaleFactor = 1.0;
  int viewStartOffsetDays = 0;
  DateTime firstDateOnScreen = DateTime.now();

  void scrollCalendar(double offset) {
    scroll += offset;
    notifyListeners();
  }

  void scaleCalendar(double scale) {
    scaleFactor = scale;
    notifyListeners();
  }

  void determinateViewPortDatesLimits({required BuildContext context}) {
    datesPerScreen = MediaQuery.of(context).size.height ~/ dayEntryHeight;
    viewStartOffsetDays = -datesPerScreen;
    dateStartView = currentDate.add(Duration(days: viewStartOffsetDays));
    dateEndView = currentDate.add(Duration(days: datesPerScreen * 2));
    widgetWidth = MediaQuery.of(context).size.width;
  }

  List<Widget> updateView() {
    List<Widget> viewBuffer = [];
    final start = dateStartView;
    final end = dateEndView;
    DateTime? titleBarDate;
    final scaledHeight = dayEntryHeight * scaleFactor;
    final viewStartOffset = viewStartOffsetDays * scaledHeight;
    int i = 0;

    if (start == null || end == null) return [];

    for (DateTime d = start;
    d.compareTo(end) != 0;
    d = d.add(const Duration(days: 1))) {
      final p = scroll + viewStartOffset + i * scaledHeight;

      if (p + scaledHeight > 0 && p <= scaledHeight) {
        firstDateOnScreen = d;
      }

      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d,
        title: DateFormat("E dd").format(d),
        crossDirectionSize: widgetWidth,
        crossDirectionOffset: 70,
        alignment: Alignment.centerLeft,
        color: d.weekday == 6 || d.weekday == 7 ? Colors.grey.shade100 : null,
      ));

      if (d.month != titleBarDate?.month) {
        viewBuffer.add(generateCrossFlowItem(
          startDate: d,
          endDate: d.addMonths(1),
          title: DateFormat("MMM - yyyy").format(d),
          crossDirectionSize: 50,
          textDirection: 3,
          alignment: Alignment.center,
        ));
      }
      if (d.weekday == 1) {
        viewBuffer.add(generateCrossFlowItem(
          startDate: d,
          endDate: d.add(const Duration(days: 6)),
          title: d.weekNumber().toString(),
          crossDirectionSize: 20,
          crossDirectionOffset: 50,
          textDirection: 3,
          alignment: Alignment.center,
        ));
      }

      titleBarDate = d;
      i++;
    }
    return viewBuffer;
  }

  Widget generateCrossFlowItem({
    required DateTime startDate,
    required DateTime endDate,
    required String title,
    double? crossDirectionSize,
    double crossDirectionOffset = 0,
    int textDirection = 0,
    AlignmentGeometry? alignment,
    Color? color,
  }) {
    final viewStartDate = dateStartView!;
    final start =
    startDate.millisecondsSinceEpoch > viewStartDate.millisecondsSinceEpoch
        ? startDate
        : viewStartDate;
    final viewEndDate = dateEndView!;
    final end =
    endDate.microsecondsSinceEpoch < viewEndDate.microsecondsSinceEpoch
        ? endDate
        : viewEndDate;

    final scaledHeight = dayEntryHeight * scaleFactor;
    final viewStartOffset = viewStartOffsetDays * scaledHeight;

    final daysDiff = start.difference(viewStartDate).inDays;
    final topPosition =
        scroll + daysDiff * scaledHeight + viewStartOffset;
    final height = (end.difference(start).inDays + 1) * scaledHeight;

    return Positioned(
        top: topPosition + 3,
        left: crossDirectionOffset,
        width: crossDirectionSize,
        height: height,
        child: Container(
          alignment: alignment,
          decoration: BoxDecoration(
              color: color,
              border: const Border(
                  bottom: BorderSide(color: Colors.black, width: 1))),
          child: RotatedBox(quarterTurns: textDirection, child: Text(title)),
        ));
  }
}
