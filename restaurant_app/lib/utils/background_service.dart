import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:restaurant_app/api_service/api_service.dart';

import '../main.dart';
import 'notification_helper.dart';

final ReceivePort port = ReceivePort();

class BackgroundService {
  static BackgroundService? _instance;
  static const String _isolateName = 'isolate';
  static SendPort? _uiSendPort;

  BackgroundService._internal() {
    _instance = this;
  }

  factory BackgroundService() => _instance ?? BackgroundService._internal();

  void initializeIsolate() {
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      _isolateName,
    );
  }

  static Future<void> callback() async {
    print('Alarm fired!');
    int index = generateRandom();
    var results = await ApiService().getAllList();
    final NotificationHelper _notificationHelper = NotificationHelper();
    await _notificationHelper.showNotification(flutterLocalNotificationsPlugin,results,index);
    print('notif telah muncul');
    _uiSendPort ??= IsolateNameServer.lookupPortByName(_isolateName);
    _uiSendPort?.send("bagas");
  }

}

int generateRandom(){
  Random random = new Random();
  int randomNumber = random.nextInt(20);
  return randomNumber;
}
