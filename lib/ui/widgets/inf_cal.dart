import 'package:flutter/material.dart';
import 'package:inf_cal/domain/inf_cal_controller.dart';
import 'package:inf_cal/utils/widgets/keyboard_and_mouse_event_detector.dart';

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

    return KeyboardAndMouseEventDetector(
      onScroll: (d) {
        print(d);
      },
      onCtrlKey: (b) => controller.zoomMode = b,
      child: GestureDetector(
        onScaleUpdate: (details) {
          if (details.scale != 1.0) {
            controller.scaleCalendar(details.scale);
          }
          controller.scrollCalendar(details.focalPointDelta.dy);
        },
        onScaleEnd: (details) {
          controller.updateControllerValues();
          _rebuild();
        },
        child: Stack(
          children: [
            Container(color: Colors.white,),
            ...controller.updateView(),
          ],
        ),
      ),
    );
  }
}
