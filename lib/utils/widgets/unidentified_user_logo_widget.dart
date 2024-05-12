import 'package:flutter/material.dart';

class UnIdentifiedUserLogoWidget extends StatelessWidget {
  const UnIdentifiedUserLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundColor: Color(0xffE6E6E6),
      radius: 30,
      child: Icon(
        Icons.person,
        color: Color(0xffCCCCCC),
      ),
    );
  }
}
