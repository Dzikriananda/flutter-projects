
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/settings_provider.dart';
import 'package:restaurant_app/theme/color.dart';
import 'package:restaurant_app/utils/background_service.dart';
import 'package:restaurant_app/utils/notification_helper.dart';

import 'main.dart';


class SettingsActivity extends  StatefulWidget {
  const SettingsActivity({Key? key}) : super(key: key);

  @override
  _SettingsActivityState createState() => _SettingsActivityState();
}

class _SettingsActivityState extends State<SettingsActivity>{


  void toggleSwitch(bool value) {
    Provider.of<SettingsProvider>(context, listen: false).setValue();
  }


  @override
  Widget build(BuildContext context){
    return Consumer<SettingsProvider>(builder: (context,data,widget){
      return Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text('Settings'),
              leading: GestureDetector(
                child: const Icon( Icons.arrow_back_ios, color: Colors.black,  ),
                onTap: () {
                  print('keluar dari settings');
                  Navigator.pop(context);
                } ,
              )
          ),
          body: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  Text('Toogle Periodic Notification at 11 AM'),
                  Expanded(child: SizedBox.fromSize()),
                  Switch(
                    onChanged: toggleSwitch,
                    value: data.isScheduled,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.lightGreen,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                  ),
                  SizedBox(width: 10)
                ],

              ),
              ElevatedButton(
                  onPressed: () => data.activateOnce(),
                  child: Text('Munculkan Notif Sekali'),
                  style:  ElevatedButton.styleFrom(
                    primary: secondaryColor,
                  ),

              )
            ],
          )
      );
    });
  }

}