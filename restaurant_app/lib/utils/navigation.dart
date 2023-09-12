import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Navigation {
  static intentNoData(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }

  static intentWithData(String routeName, dynamic arguments) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static back() => navigatorKey.currentState?.pop();
  static backFromNotifications() => navigatorKey.currentState?.popUntil((route) => route.isFirst);

}