import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurant_app/data/restaurant_response.dart';
import 'package:restaurant_app/utils/navigation.dart';
import 'package:restaurant_app/utils/received_notifications.dart';
import 'package:rxdart/rxdart.dart';

final selectNotificationSubject = BehaviorSubject<String?>();
final didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

class NotificationHelper {
  static const _channelId = "01";
  static const _channelName = "channel_01";
  static const _channelDesc = "dicoding channel";
  static NotificationHelper? _instance;

  NotificationHelper._internal() {
    _instance = this;
  }

  factory NotificationHelper() => _instance ?? NotificationHelper._internal();

  Future<void> initNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    print(1);
    var initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    print(2);

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          log('notification payload: $payload');
        }
        print('mencoba add payload');
        selectNotificationSubject.add(payload ?? 'empty payload');
        print("berhasil add payload");
      },
    );
  }

  void requestIOSPermissions(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void configureDidReceiveLocalNotificationSubject(
      BuildContext context, String route) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.pushNamed(context, route,
                    arguments: receivedNotification);
              },
            )
          ],
        ),
      );
    });
  }

  Future<void> showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,RestaurantResponse results,int index) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        _channelId, _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    var titleNotification = "Rekomendasi restoran untuk anda!";
    var titleNews = results.restaurants[index].name;
    var id = results.restaurants[index].id;

    await flutterLocalNotificationsPlugin.show(
      0,
      titleNotification,
      titleNews,
      platformChannelSpecifics,
      payload: id,
    );
  }

  void configureSelectNotificationSubject(BuildContext context, String route) {
    selectNotificationSubject.stream.listen((String? payload) async {
      try{
        Navigation.intentWithData(route,{'restaurantId' : payload,'isFromNotification': true});
      }
      catch(e){
        print(e.toString());
      }
    });
  }
}