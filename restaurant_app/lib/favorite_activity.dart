import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/favorite_provider.dart';
import 'package:restaurant_app/data/restaurant_response.dart';
import 'package:restaurant_app/theme/color.dart';
import 'package:restaurant_app/utility/build_stars.dart';



class FavoriteActivity extends StatefulWidget{
  late List<Restaurant> restaurants;

  FavoriteActivity({Key? key, required this.restaurants});

  @override
  State<FavoriteActivity> createState() => _FavoriteActivityState();
}

class _FavoriteActivityState extends State<FavoriteActivity> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<FavoriteProvider>(context, listen: false).
      initiate(widget.restaurants);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(builder: (context,data,widget){
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,

          title: Text('Favorites'),
        ),
        body: ListResto(data),
        backgroundColor: primaryColor,
      );
    });
  }
}

Widget ListResto(FavoriteProvider data){
  if(data.state == ResultState.noData){
    return Center(
      child: Text('Belum ada restoran'),
    );
  }
  else{
    return ListView.builder(
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 25),
        itemCount: data.listRestaurantFav.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildArticleItem(context, data.listRestaurantFav[index]);
        });
  }
}



Widget _buildArticleItem(BuildContext context, Restaurant _items) {
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context,'/detailActivity',arguments: {'restaurantId' : _items.id,'isFromNotification': false}).then(
              (value) =>
              Provider.of<FavoriteProvider>(context, listen: false).refresh() //force refresh if pop into the fav activity
      );
    },
    child: Card(
        color: secondaryColor,
        child: Row(
          children: [
            const SizedBox(
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
                        const Icon(Icons.location_pin),
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