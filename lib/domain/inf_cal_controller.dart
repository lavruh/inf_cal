import 'package:flutter/material.dart';
import 'package:inf_cal/utils/date_extension.dart';
import 'package:intl/intl.dart';

class InfCalController extends ChangeNotifier {
  double entryHeight = 30.0;
  double widgetWidth = 100.0;
  double scroll = 0.0;
  int entriesPerScreen = 0;
  DateTime? bufferStart;
  DateTime? bufferEnd;
  DateTime currentDate = DateTime.now();
  double scaleFactor = 1.0;
  int viewStartOffsetEntries = 0;
  int amountOfGeneratedViewItems = 0;
  DateTime firstEntryOnScreen = DateTime.now();
  ScaleLevel scaleLevel = ScaleLevel.minutes;
  bool _zoomMode = false;
  double _mouseScale = 1;
  Duration _iteration = const Duration(minutes: 1);

  bool get zoomMode => _zoomMode;

  set zoomMode(bool value) {
    _zoomMode = value;
    if (value) _mouseScale = 1;
    notifyListeners();
  }

  void scrollCalendar(double offset) {
    scroll += offset;
    notifyListeners();
  }

  void scaleCalendar(double scale) {
    scaleFactor = scale;
    notifyListeners();
  }

  void mouseScaleCalendar(double scale) {
    if (scale > 0) _mouseScale += 0.1;
    if (scale < 0) _mouseScale -= 0.1;
    scaleCalendar(_mouseScale);
  }

  void determinateViewPortDatesLimits({required BuildContext context}) {
    entriesPerScreen = MediaQuery.of(context).size.height ~/ entryHeight;
    viewStartOffsetEntries = -entriesPerScreen * 3;
    bufferStart = currentDate.add(_iteration * viewStartOffsetEntries);
    if (scaleLevel != ScaleLevel.minutes) {
      bufferStart = bufferStart?.copyWith(minute: 0, second: 0);
    }

    bufferEnd = currentDate.add(_iteration * entriesPerScreen * 4);
    widgetWidth = MediaQuery.of(context).size.width;
  }

  List<Widget> updateView() {
    List<Widget> viewBuffer = [];
    final start = bufferStart;
    final end = bufferEnd;
    final scaledHeight = (entryHeight * scaleFactor);
    final viewStartOffset = viewStartOffsetEntries * scaledHeight;
    int i = 0;

    if (start == null || end == null) return [];
    for (DateTime d = start;
        d.millisecondsSinceEpoch < end.millisecondsSinceEpoch;
        d = d.add(_iteration)) {
      final p = scroll + viewStartOffset + i * scaledHeight;
      if (p + scaledHeight > 0 && p <= scaledHeight) firstEntryOnScreen = d;

      if (scaleLevel == ScaleLevel.months) {
        viewBuffer.addAll(_generateMonthsView(i, d));
      }
      if (scaleLevel == ScaleLevel.days) {
        viewBuffer.addAll(_generateDaysView(i, d));
      }
      if (scaleLevel == ScaleLevel.hours) {
        viewBuffer.addAll(_generateHoursView(i, d));
      }
      if (scaleLevel == ScaleLevel.minutes) {
        viewBuffer.addAll(_generateMinutesView(i, d));
      }
      i++;
    }
    amountOfGeneratedViewItems = i;
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
    final durationDivider = _iteration.inMicroseconds;
    final daysDiff =
        start.difference(viewStartDate).inMicroseconds ~/ durationDivider;

    final topPosition = scroll + daysDiff * scaledHeight + viewStartOffset;
    final height = (end.difference(start).inMicroseconds ~/ durationDivider) *
        scaledHeight;

    return Positioned(
        top: topPosition,
        left: crossDirectionOffset,
        width: crossDirectionSize,
        height: height,
        child: Container(
          alignment: alignment,
          decoration: BoxDecoration(
              color: color,
              border:
                  const Border(top: BorderSide(color: Colors.black, width: 1))),
          child: Stack(children: [
            Positioned(
              top: topPosition < 0 ? -(topPosition) : 0,
              child:
                  RotatedBox(quarterTurns: textDirection, child: Text(title)),
            ),
          ]),
        ));
  }

  void switchScaleLevel(int i) {
    final level = scaleLevel.index;
    if (level + i < 0 || level + i > ScaleLevel.values.length - 1) return;
    scaleLevel = ScaleLevel.values[scaleLevel.index + i];
    entryHeight = 21.0;
    if (scaleLevel == ScaleLevel.days) _iteration = const Duration(days: 1);
    if (scaleLevel == ScaleLevel.hours) _iteration = const Duration(hours: 1);
    if (scaleLevel == ScaleLevel.minutes) {
      _iteration = const Duration(minutes: 1);
    }
    updateControllerValues();
  }

  void updateControllerValues() {
    currentDate = firstEntryOnScreen;
    entryHeight *= scaleFactor;
    scaleFactor = 1.0;
    scroll = 0.0;
    if (entryHeight < 20) switchScaleLevel(1);
    if (entryHeight > 100) switchScaleLevel(-1);
  }

  List<Widget> _generateMinutesView(int i, DateTime d) {
    List<Widget> viewBuffer = [];
    viewBuffer.add(generateCrossFlowItem(
      startDate: d,
      endDate: d.add(_iteration),
      title: DateFormat("HH : mm").format(d),
      crossDirectionSize: widgetWidth,
      crossDirectionOffset: 40,
      alignment: Alignment.centerLeft,
      color: i % 2 == 0 ? Colors.grey.shade50 : null,
    ));

    if (i == 0 || (d.hour == 0 && d.minute == 0)) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.add(const Duration(days: 1)),
        title: DateFormat("EEEE dd MMMM yyyy").format(d),
        crossDirectionSize: 20,
        crossDirectionOffset: 20,
        textDirection: 3,
        alignment: Alignment.center,
        color: Colors.grey.shade100,
      ));
    }
    if (i == 0 || (d.weekday == 1 && d.hour == 0 && d.minute == 0)) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.add(const Duration(days: 6)),
        title: "Week: ${d.weekNumber()}",
        crossDirectionSize: 20,
        crossDirectionOffset: 0,
        textDirection: 3,
        alignment: Alignment.topLeft,
      ));
    }
    return viewBuffer;
  }

  List<Widget> _generateHoursView(int i, DateTime d) {
    List<Widget> viewBuffer = [];
    viewBuffer.add(generateCrossFlowItem(
      startDate: d,
      endDate: d.add(_iteration),
      title: DateFormat("HH:00").format(d),
      crossDirectionSize: widgetWidth,
      crossDirectionOffset: 40,
      alignment: Alignment.centerLeft,
      color: i % 2 == 0 ? Colors.grey.shade50 : null,
    ));
    if (i == 0 || (d.hour == 0 && d.minute == 0)) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.add(const Duration(days: 1)),
        title: DateFormat("EEEE dd MMMM yyyy").format(d),
        crossDirectionSize: 20,
        crossDirectionOffset: 20,
        textDirection: 3,
        color: Colors.grey.shade100,
      ));
    }
    if (i == 0 || (d.weekday == 1 && d.hour == 0 && d.minute == 0)) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.add(const Duration(days: 6)),
        title: "Week: ${d.weekNumber()}",
        crossDirectionSize: 20,
        crossDirectionOffset: 0,
        textDirection: 3,
      ));
    }
    return viewBuffer;
  }

  List<Widget> _generateDaysView(int i, DateTime d) {
    List<Widget> viewBuffer = [];
    viewBuffer.add(generateCrossFlowItem(
      startDate: d,
      endDate: d.add(const Duration(days: 1)),
      title: DateFormat("EEE dd").format(d),
      crossDirectionSize: widgetWidth,
      crossDirectionOffset: 70,
      alignment: Alignment.centerLeft,
      color: i % 2 == 0 ? Colors.grey.shade50 : null,
    ));
    if (i == 0 || d.day == 1) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.addMonths(1),
        title: DateFormat("MMM - yyyy").format(d),
        crossDirectionSize: 50,
        textDirection: 3,
        alignment: Alignment.center,
      ));
    }
    if (i == 0 || d.weekday == 1) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.add(const Duration(days: 6)),
        title: "wk: ${d.weekNumber()}",
        crossDirectionSize: 20,
        crossDirectionOffset: 50,
        textDirection: 3,
        alignment: Alignment.topLeft,
      ));
    }
    return viewBuffer;
  }

  List<Widget> _generateMonthsView(int i, DateTime d) {
    List<Widget> viewBuffer = [];
    if (i == 0 || (d.month == 1 && d.day == 1)) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.addMonths(12),
        title: DateFormat("yyyy").format(d),
        crossDirectionSize: 20,
        textDirection: 3,
        alignment: Alignment.center,
      ));
    }
    if (i == 0 || d.day == 1) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.addMonths(1),
        title: DateFormat("MMM").format(d),
        crossDirectionSize: 20,
        crossDirectionOffset: 20,
        textDirection: 3,
        alignment: Alignment.center,
      ));
    }
    if (i == 0 || d.weekday == 1) {
      viewBuffer.add(generateCrossFlowItem(
        startDate: d,
        endDate: d.add(const Duration(days: 6)),
        title: "wk: ${d.weekNumber()}",
        crossDirectionSize: widgetWidth,
        crossDirectionOffset: 40,
        textDirection: 0,
        alignment: Alignment.topLeft,
        color: i % 2 == 0 ? Colors.grey.shade50 : null,
      ));
    }
    return viewBuffer;
  }
}

enum ScaleLevel { minutes, hours, days, months }
