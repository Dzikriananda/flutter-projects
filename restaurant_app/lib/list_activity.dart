
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/restaurant_provider.dart';
import 'package:restaurant_app/theme/color.dart';
import 'package:restaurant_app/data/restaurant_response.dart';
import 'package:restaurant_app/utility/build_stars.dart';
import 'package:restaurant_app/database/database_helper.dart';
import 'package:restaurant_app/utils/navigation.dart';
import 'package:restaurant_app/utils/notification_helper.dart';


class ListActivity extends  StatefulWidget {
  const ListActivity({Key? key}) : super(key: key);

  @override
  _ListActivityState createState() => _ListActivityState();
}

class _ListActivityState extends State<ListActivity>{
  final NotificationHelper _notificationHelper = NotificationHelper();

  final TextEditingController _textEditingController = TextEditingController();
  final focusNode = FocusNode();
  final databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _notificationHelper.configureSelectNotificationSubject(
        context, '/detailActivity');
    _notificationHelper.configureDidReceiveLocalNotificationSubject(
        context, '/detailActivity');
  }

  @override
  void dispose(){
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(builder: (context,data,widget){
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text('Restaurant App'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: FloatingActionButton(
                heroTag: "btn1",
                backgroundColor: secondaryColor,
                onPressed: (){
                  print('ke settings bukan detail');
                  Navigator.pushNamed(context, '/settingsActivity');
                },
                child: Icon(Icons.settings),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: FloatingActionButton(
                heroTag: "btn2",
                backgroundColor: secondaryColor,
                onPressed: (){
                  if(data.state == ResultState.hasData){
                    print('panjang sblm dikirim ke fav acti : ${data.result.length}');
                    Navigator.pushNamed(context, '/favoriteActivity',arguments: data.result);
                  }
                },
                child: Icon(Icons.favorite),
              ),
            ),

          ],
        ),
        body: Column(
          children: [
            const SizedBox(height : 5),
            Row(
              children: [
                const SizedBox(width : 5),
                Expanded(child: SearchBar(
                  controller: _textEditingController,
                  elevation: MaterialStateProperty.all(20.0),
                  constraints: const BoxConstraints(),
                  side: MaterialStateProperty.all(const BorderSide(color: secondaryColor)),
                  shape: MaterialStateProperty.all(const ContinuousRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    // side: BorderSide(color: Colors.pinkAccent),
                  )),
                  overlayColor: MaterialStateProperty.all(secondaryColor),
                  shadowColor: MaterialStateProperty.all(Colors.pinkAccent),
                  backgroundColor: MaterialStateProperty.all(
                      primaryColor
                  ),
                  hintText: 'Masukkan Kata Kunci',
                  hintStyle: MaterialStateProperty.all(const TextStyle(color: Colors.grey)),
                  textStyle: MaterialStateProperty.all(
                      const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)
                  ),
                  onChanged: (String value) {
                  },
                  onSubmitted: (String value) {
                    data.searchRestaurant(value);
                  },
                  leading: const Icon(Icons.search),
                ),
                ),
                const SizedBox(width : 5),
              ],
            ),
            const SizedBox(height : 5),
            Flexible(child: ListResto(data)),
          ],
        ),
        backgroundColor: primaryColor,
      );
    });
  }
}


Widget ListResto(RestaurantProvider data){
   if(data.state == ResultState.loading){
     print("loading di main");
     return const Center(child: CircularProgressIndicator(
       color: Colors.black,
     ));
   }
   else if(data.state == ResultState.hasData){
     return ListView.builder(
         padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 25),
         itemCount: data.result.length,
         itemBuilder: (BuildContext context, int index) {
           return _buildArticleItem(context, data.result[index]);
         });
   } else if (data.state == ResultState.noData) {
     return Center(
       child: Material(
         child: Text(data.message),
       ),
     );
   } else if (data.state == ResultState.error) {
     return Center(
       child: Material(
         child: Text(data.message),
       ),
     );
   } else if (data.state == ResultState.noConnection) {
     return Center(
       child: Material(
         child: Text(data.message),
       ),
     );
   }
   else {
     return const Center(
       child: Material(
         child: Text(''),
       ),
     );
   }
}



Widget _buildArticleItem(BuildContext context, Restaurant _items) {
  return InkWell(
    onTap: () {
      Navigation.intentWithData('/detailActivity',{'restaurantId' : _items.id,'isFromNotification': false});
    },
    child: Card(
      color: secondaryColor,
      child: Row(
            children: [
              SizedBox(
                width: 10.0,
              ),
              Flexible(
                  child: ClipRRect(
                    child: Image.network(
                      "https://restaurant-api.dicoding.dev/images/large/${_items.pictureId}",
                      fit: BoxFit.fill,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                    borderRadius: BorderRadius.circular(10),
                  )
              ),
              SizedBox(
                width: 10.0,
              ),
              Container(
                child: Flexible(
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          _items.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      StarsRow(_items.rating,false),
                      Row(
                        children: [
                          Icon(Icons.location_pin),
                          Text(
                              _items.city,
                              style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
}





