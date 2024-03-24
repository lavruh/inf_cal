
import 'package:flutter/material.dart';
import 'package:inf_cal/utils/date_extension.dart';
import 'package:intl/intl.dart';

class InfCalController extends ChangeNotifier {
  double entryHeight = 50.0;
  double widgetWidth = 100.0;
  double scroll = 0.0;
  List<Widget> viewBuffer = [];
  int entriesPerScreen = 0;
  DateTime? bufferStart;
  DateTime? bufferEnd;
  DateTime currentDate = DateTime.now();
  double scaleFactor = 1.0;
  int viewStartOffsetEntries = 0;
  DateTime firstEntryOnScreen = DateTime.now();

  void scrollCalendar(double offset) {
    scroll += offset;
    notifyListeners();
  }

  void scaleCalendar(double scale) {
    scaleFactor = scale;
    notifyListeners();
  }

  void determinateViewPortDatesLimits({required BuildContext context}) {
    entriesPerScreen = MediaQuery.of(context).size.height ~/ entryHeight;
    viewStartOffsetEntries = -entriesPerScreen;
    bufferStart = currentDate.add(Duration(days: viewStartOffsetEntries));
    bufferEnd = currentDate.add(Duration(days: entriesPerScreen * 2));
    widgetWidth = MediaQuery.of(context).size.width;
  }

  List<Widget> updateView() {
    List<Widget> viewBuffer = [];
    final start = bufferStart;
    final end = bufferEnd;
    DateTime? titleBarDate;
    final scaledHeight = entryHeight * scaleFactor;
    final viewStartOffset = viewStartOffsetEntries * scaledHeight;
    int i = 0;

    if (start == null || end == null) return [];

    for (DateTime d = start;
    d.compareTo(end) != 0;
    d = d.add(const Duration(days: 1))) {
      final p = scroll + viewStartOffset + i * scaledHeight;

      if (p + scaledHeight > 0 && p <= scaledHeight) {
        firstEntryOnScreen = d;
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
    final viewStartDate = bufferStart!;
    final start =
    startDate.millisecondsSinceEpoch > viewStartDate.millisecondsSinceEpoch
        ? startDate
        : viewStartDate;
    final viewEndDate = bufferEnd!;
    final end =
    endDate.microsecondsSinceEpoch < viewEndDate.microsecondsSinceEpoch
        ? endDate
        : viewEndDate;

    final scaledHeight = entryHeight * scaleFactor;
    final viewStartOffset = viewStartOffsetEntries * scaledHeight;

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
