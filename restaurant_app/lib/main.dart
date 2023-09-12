import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/restaurant_response.dart';
import 'package:restaurant_app/database/database_helper.dart';
import 'package:restaurant_app/detail_activity.dart';
import 'package:restaurant_app/provider/favorite_provider.dart';
import 'package:restaurant_app/provider/restaurant_detail_provider.dart';
import 'package:restaurant_app/provider/settings_provider.dart';
import 'package:restaurant_app/theme/text_theme.dart';
import 'package:restaurant_app/list_activity.dart';
import 'dart:io';
import 'package:restaurant_app/theme/color.dart';
import 'package:restaurant_app/provider/restaurant_provider.dart';
import 'package:restaurant_app/api_service/api_service.dart';
import 'package:restaurant_app/favorite_activity.dart';
import 'package:restaurant_app/utils/background_service.dart';
import 'package:restaurant_app/utils/navigation.dart';
import 'package:restaurant_app/utils/notification_helper.dart';
import 'package:restaurant_app/settings_activity.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void>main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  final BackgroundService service = BackgroundService();
  service.initializeIsolate();
  await AndroidAlarmManager.initialize();
  final NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initNotifications(flutterLocalNotificationsPlugin);
  notificationHelper.requestIOSPermissions(flutterLocalNotificationsPlugin);
  print('keadaan stream saat init app: ${selectNotificationSubject.isClosed.toString()}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => RestaurantProvider(apiService: ApiService())),
          ChangeNotifierProvider(create: (context) => RestaurantDetailProvider(apiService: ApiService(),database: DatabaseHelper())),
          ChangeNotifierProvider(create: (context) => FavoriteProvider(apiService: ApiService(),database: DatabaseHelper())),
          ChangeNotifierProvider(create: (context) => SettingsProvider())

        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Restaurant App',
          theme: ThemeData(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: primaryColor,
                onPrimary: Colors.black,
                secondary: secondaryColor,
              ),
              useMaterial3: true,
              textTheme: textTheme
          ),
          initialRoute: '/listActivity',
          routes: {
            '/listActivity': (context) =>  ListActivity(),
            '/detailActivity': (context) {
              final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
              return DetailActivity(
                restaurantId: arguments['restaurantId'] as String,
                isFromNotification: arguments['isFromNotification'] as bool,
              );
            },
            '/favoriteActivity': (context) => FavoriteActivity(
              restaurants: ModalRoute.of(context)?.settings.arguments as List<Restaurant>,
            ),
            '/settingsActivity': (context) =>  SettingsActivity(),
          },
        ),
    );
  }
}



class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
