import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

Future<void> clearUserPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

void navigateToPage(BuildContext context, Widget page,
    {PageTransitionType transitionType = PageTransitionType.rightToLeft,
    Duration duration = const Duration(seconds: 1)}) {
  Navigator.pushAndRemoveUntil(
    context,
    PageTransition(
      type: transitionType,
      duration: duration,
      child: page,
    ),
    (route) => false,
  );
}

Future<void> logoutAndNavigate(BuildContext context, Widget page) async {
  await clearUserPreferences();
  navigateToPage(context, page);
}
