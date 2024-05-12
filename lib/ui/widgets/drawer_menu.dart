import 'package:flutter/material.dart';
import 'package:inf_cal/utils/widgets/user_auth_widget.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      elevation: 3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [UserAuthWidget()],
        ),
      ),
    );
  }
}
