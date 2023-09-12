
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/background_service.dart';
import '../utils/date_helper.dart';

class SettingsProvider extends ChangeNotifier{
  bool _isScheduled = false;

  bool get isScheduled => _isScheduled;

  Function() get setValue => saveValue;

  SettingsProvider(){
    getValue();
  }


  Future<void> activateOnce() async{
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 5),
      3,
      BackgroundService.callback,
      exact: true,
      wakeup: true,
    );
  }



  Future<void> getValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _isScheduled = sharedPreferences.getBool('isActive') ?? false;
    notifyListeners();
    print('get value : $_isScheduled');
  }


  Future<void> saveValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(_isScheduled){
      sharedPreferences.setBool('isActive',false);
    }
    else{
      sharedPreferences.setBool('isActive',true);
    }
    await getValue();
    scheduledNotification(_isScheduled);
    notifyListeners();
  }

  Future<bool> scheduledNotification(bool value) async {
    _isScheduled = value;

    final desiredTime = DateTimeHelper.format();
    print(desiredTime);

    if (_isScheduled) {
      print('Scheduling Activated');
      notifyListeners();
      return await AndroidAlarmManager.periodic(
        const Duration(seconds: 5),
        1,
        BackgroundService.callback,
        startAt: desiredTime,
        exact: true,
        wakeup: true,
      );
    } else {
      print('Scheduling Canceled');
      notifyListeners();
      return await AndroidAlarmManager.cancel(1);
    }
  }


}