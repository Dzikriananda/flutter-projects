
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/restaurant_detail_response.dart';
import 'package:restaurant_app/provider/restaurant_detail_provider.dart';
import 'package:restaurant_app/theme/color.dart';
import 'package:restaurant_app/utility/build_stars.dart';
import 'package:restaurant_app/utils/navigation.dart';

class DetailActivity extends StatefulWidget {
  final String restaurantId;
  final bool isFromNotification;

  const DetailActivity ({super.key,required this.restaurantId,required this.isFromNotification});

  @override
  State<DetailActivity> createState() => _DetailActivityState();
}

class _DetailActivityState extends State<DetailActivity> {


  @override
  void initState() {
    super.initState();
    print('initState at detail');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<RestaurantDetailProvider>(context, listen: false).
      fetchRestaurantDetail(widget.restaurantId);
      });

  }
  @override
  Widget build(BuildContext context) {
    print('widget build at detail');
    return Scaffold(
        backgroundColor: primaryColor,
        body: Consumer<RestaurantDetailProvider>(
          builder: (context,data,widget){
            return BuildScreen(context, data);
          }
        ),
        appBar: AppBar(
          title: const Text('Restaurant App'),
          leading: GestureDetector(
            child: const Icon( Icons.arrow_back_ios, color: Colors.black,  ),
            onTap: () {
              if(widget.isFromNotification){
                Navigation.backFromNotifications();
              }
              else Navigation.back();
            } ,
          ) ,
          backgroundColor: primaryColor,
        ),
      );
  }
}

Widget BuildScreen(BuildContext context, RestaurantDetailProvider data){
  if(data.state == ResultState.loading){
    return const Center(child: CircularProgressIndicator(
      color: Colors.black,
    ));
  }
  else if(data.state == ResultState.hasData){
    return RestaurantPage(context,data.result.restaurant,data);
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

Widget RestaurantPage(BuildContext context,Restaurant restaurant,RestaurantDetailProvider viewmodel){
  TextEditingController _textFieldControllerFirst = TextEditingController();
  TextEditingController _textFieldControllerSecond = TextEditingController();

  String name='';
  String review='';

  bool isFavorite = viewmodel.isFavorite;
  print("isFavorite di activity: ${viewmodel.isFavorite}");

  return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network("https://restaurant-api.dicoding.dev/images/large/${restaurant.pictureId}"),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(100)
            ),
            child: Column(
              children: [
                Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                StarsRow(restaurant.rating,true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_pin),
                    Text(
                      restaurant.city,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ],

            ),
            width: 350,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(restaurant.description),
          ),
          ClipOval(
            child: Material(
              color: secondaryColor, // Button color
              child: InkWell(
                splashColor: Colors.red, // Splash color
                onTap: () {
                  if(isFavorite){
                    viewmodel.deleteFavorite(restaurant.id);
                    showToast('${restaurant.name} Dihapus Dari Favorit');
                  }
                  else{
                    viewmodel.addFavorite(restaurant.name,restaurant.id);
                    showToast('${restaurant.name} Ditambah Ke Favorit');
                  }
                },
                child: SizedBox(
                    width: 56,
                    height: 56,
                    child: isFavorite? Icon(Icons.favorite) : Icon(Icons.favorite_outline)
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text("Menu: ", style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 10),
          Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text("Foods: ", style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          Container(
            height: 60,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: restaurant.menus.foods.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    child: Card(
                      color: secondaryColor,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child:  Text(
                          restaurant.menus.foods[index].name,
                          style: Theme.of(context).textTheme.headlineSmall ,
                        ), //Container
                      ),
                    ),
                  );
                }),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text("Drinks: ", style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          Container(
            height: 60,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: restaurant.menus.drinks.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    child: Card(
                      color: secondaryColor,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Text(
                          restaurant.menus.drinks[index].name,
                          style: Theme.of(context).textTheme.headlineSmall ,
                        ),//Container
                      ),
                    ),
                  );
                }),
          ),
          Text("Reviews: ", style: Theme.of(context).textTheme.headlineMedium),
          TextButton.icon(
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Add Reviews"),
                    content:  Container(
                      height: 100,
                      child: Column(
                        children: [
                          TextField(
                              controller: _textFieldControllerFirst,
                              decoration: InputDecoration(hintText: "Masukkan nama anda"),
                              onChanged: (text) => name=text
                          ),
                          TextField(
                            controller: _textFieldControllerSecond,
                            decoration: InputDecoration(hintText: "Masukkan review anda"),
                            onChanged: (text){
                              review = text;
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: secondaryColor,
                          ),
                          padding: const EdgeInsets.all(14),
                          child: const Text("back"),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if(name=='' && review ==''){
                            var snackBar = SnackBar(content: Text('Nama dan Review tidak boleh Kosong!'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          else if(name==''){
                            var snackBar = SnackBar(content: Text('Nama tidak boleh Kosong!'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          else if(review==''){
                            var snackBar = SnackBar(content: Text('Review tidak boleh Kosong!'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          else{
                            viewmodel.postReview(restaurant.id,name,review);
                            Navigator.of(ctx).pop();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: secondaryColor,
                          ),
                          padding: const EdgeInsets.all(14),
                          child: const Text("add"),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  backgroundColor: secondaryColor,
                  textStyle: Theme.of(context).textTheme.titleLarge),
              icon: const Icon(Icons.add),
              label: const Text('Add Reviews')),
          Container(
            height: 300,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: restaurant.customerReviews.length,
                itemBuilder: (BuildContext context, int index) {
                  return  Card(
                    color: secondaryColor,
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(Icons.person_2_rounded),
                      title: Text(
                          '${restaurant.customerReviews[index].name} - ${restaurant.customerReviews[index].date}',
                          style: Theme.of(context).textTheme.titleSmall
                      ),
                      subtitle: Text(
                        '${restaurant.customerReviews[index].review}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  );
                }),
          )


        ],
      )
  );
}

void showToast(String dialog){
  Fluttertoast.showToast(
    msg: dialog,
    toastLength: Toast.LENGTH_SHORT,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 25,
    gravity: ToastGravity.TOP,
  );
}






