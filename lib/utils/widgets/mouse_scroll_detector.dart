import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MouseScrollDetector extends StatelessWidget {
  final void Function(PointerScrollEvent event) onScroll;
  final Widget child;

  const MouseScrollDetector({
    super.key,
    required this.onScroll,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) onScroll(pointerSignal);
      },
      child: child,
    );
  }
}
