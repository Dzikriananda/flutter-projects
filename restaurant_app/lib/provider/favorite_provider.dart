import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:restaurant_app/database/restaurant.dart';
import 'package:restaurant_app/database/database_helper.dart';
import 'package:restaurant_app/data/restaurant_response.dart';

import '../api_service/api_service.dart';

enum ResultState { loading, noData, hasData, error,noConnection }

class FavoriteProvider extends ChangeNotifier{
    final DatabaseHelper database;
    final ApiService apiService;
    ResultState get state => _state;
    late ResultState _state;
    String _message = '';
    String get message => _message;
    List<String> _favoriteId = [];
    List<Restaurant> _listRestaurantFav =[];
    List<Restaurant> get listRestaurantFav => _listRestaurantFav;


    FavoriteProvider({required this.database,required this.apiService}){
      _state = ResultState.loading;
    }




    Future<void> initiate(List<Restaurant> listResto) async{
      if(_listRestaurantFav.length > 0){
        clearData();
      }
      await getFavorite();
      filterFavorite(listResto);
    }

    //force refresh if pop into the fav activity
    Future<void> refresh() async {
      await getFavorite();
      var listDeepCopy = _listRestaurantFav.toList();
      clearData();
      filterFavorite(listDeepCopy);
    }


    Future<void> getFavorite() async {
       List<RestaurantSQLite> results = await database.getFavorite();
       _favoriteId = results.map((e) => e.restaurantId).toList();
       notifyListeners();
    }

    void filterFavorite(List<Restaurant> _listRestaurant) {
      _listRestaurant.forEach(
              (element) {
                if(_favoriteId.contains(element.id)){
                  _listRestaurantFav.add(element);
                }
              });
      if(_listRestaurantFav.isEmpty){
        _state = ResultState.noData;
        notifyListeners();
      }
      else{
        _state = ResultState.hasData;
        notifyListeners();
      }
    }

    Future<bool> checkInternet(
        InternetConnectionChecker internetConnectionChecker,
        ) async {
      final bool isConnected = await InternetConnectionChecker().hasConnection;
      return isConnected;
    }

    void clearData(){
      _listRestaurantFav.clear();
    }

}