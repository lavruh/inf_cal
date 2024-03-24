
import 'package:flutter/material.dart';
import 'package:inf_cal/domain/inf_cal_controller.dart';
import 'package:inf_cal/utils/widgets/mouse_scroll_detector.dart';

class InfCal extends StatefulWidget {
  const InfCal({super.key, required this.controller});

  final InfCalController controller;

  @override
  State<InfCal> createState() => _InfCalState();
}

class _InfCalState extends State<InfCal> {
  late InfCalController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.addListener(_rebuild);
  }

  _rebuild() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.determinateViewPortDatesLimits(context: context);

    // _updateView();
    return MouseScrollDetector(
      child: GestureDetector(
        onScaleUpdate: (details) {
          if (details.scale != 1.0) {
            controller.scaleCalendar(details.scale);
          }
          controller.scrollCalendar(details.focalPointDelta.dy);
        },
        onScaleEnd: (details) {
          controller.currentDate = controller.firstDateOnScreen;
          controller.dayEntryHeight *= controller.scaleFactor;
          controller.scaleFactor = 1.0;
          controller.scroll = 0.0;
          _rebuild();
        },
        child: Stack(
          children: controller.updateView(),
        ),
      ),
      onScroll: (event) => controller.scrollCalendar(event.scrollDelta.dy),
    );
  }
}