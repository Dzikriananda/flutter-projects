
import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/restaurant_response.dart';
import 'package:restaurant_app/api_service/api_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum ResultState { loading, noData, hasData, error,noConnection }

class RestaurantProvider extends ChangeNotifier {
  final ApiService apiService;

  RestaurantProvider({required this.apiService}) {
    _fetchAllRestaurant();
  }

  late List<Restaurant> _listRestaurant;
  late ResultState _state;
  String _message = '';

  String get message => _message;

  List<Restaurant> get result => _listRestaurant;

  Function(String) get searchRestaurant => _searchRestaurant;
  Function() get fetchAllRestaurant => _fetchAllRestaurant;




  ResultState get state => _state;


  Future<dynamic> _fetchAllRestaurant() async {
    try {
      _state = ResultState.loading;
      notifyListeners();
      final isConnected = await checkInternet(InternetConnectionChecker());
      if(isConnected){
        final resto = await apiService.getAllList();
        if (resto.count == 0) {
          _state = ResultState.noData;
          notifyListeners();
          return _message = 'Empty Data';
        } else {
          _state = ResultState.hasData;
          notifyListeners();
          //_restaurantResponse = resto;
          _listRestaurant = resto.restaurants;
        }
      }
      else{
        _state = ResultState.noConnection;
        notifyListeners();
        return _message = 'No Network Available';
      }
    } catch (e) {
      _state = ResultState.error;
      notifyListeners();
      return _message = 'Error --> $e';
    }
  }

  Future<dynamic> _searchRestaurant(String query) async {
    try {
      _state = ResultState.loading;
      notifyListeners();
      final isConnected = await checkInternet(InternetConnectionChecker());
      if(isConnected){
        final resto = await apiService.getQueryRestaurant(query);
        if (resto.founded == 0) {
          _state = ResultState.noData;
          notifyListeners();
          return _message = 'Empty Data';
        } else {
          _state = ResultState.hasData;
          notifyListeners();
          //_restaurantResponse = resto;
          _listRestaurant = resto.restaurants;
        }
      }
      else{
        _state = ResultState.noConnection;
        notifyListeners();
        return _message = 'No Network Available';
      }
    } catch (e) {
      _state = ResultState.error;
      notifyListeners();
      return _message = 'Error --> $e';
    }
  }
}



Future<bool> checkInternet(
    InternetConnectionChecker internetConnectionChecker,
    ) async {
  final bool isConnected = await InternetConnectionChecker().hasConnection;
  print(isConnected.toString());
  return isConnected;
}