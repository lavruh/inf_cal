import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inf_cal/domain/calendar_user.dart';
import 'package:inf_cal/utils/widgets/unidentified_user_logo_widget.dart';
import 'dart:io' show Platform;

class UserAuthWidget extends StatelessWidget {
  const UserAuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<CalendarUser>(builder: (state) {
      final user = state.userName.value;

      Widget body = ListTile(
        leading: const UnIdentifiedUserLogoWidget(),
        title:
            user != null ? Text(user) : const Text("Unidentified user"),
        subtitle: state.isLoggedIn.value
            ? TextButton(
                onPressed: () => state.googleSignOut(),
                child: const Text("Sign out"))
            : TextButton(
                onPressed: () => signIn(state, context),
                child: const Text("Sign in")),
      );

      print("Widget user $user");
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: body,
      );
    });
  }

  void signIn(CalendarUser state, BuildContext context) {
    if (kIsWeb) {
      state.googleDesktopSignIn(
          (url) async => await tokenRequestDialog(url, context));
    } else {
      if (Platform.isAndroid) state.googleSignInAndroid();
      if (Platform.isLinux) {
        state.googleDesktopSignIn(
            (url) async => await tokenRequestDialog(url, context));
      }
    }
  }

  Future<String> tokenRequestDialog(String url, BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Column(children: [
                SelectableText(url),
                TextField(
                  onSubmitted: (v) => Get.back(result: v),
                ),
              ]),
            ));
    return result ?? "";
  }
}
