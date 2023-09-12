import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/restaurant_detail_response.dart';
import 'package:restaurant_app/api_service/api_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:restaurant_app/database/database_helper.dart';


enum ResultState { loading, noData, hasData, error,noConnection }

class RestaurantDetailProvider extends ChangeNotifier {
  final ApiService apiService;
  final DatabaseHelper database;

  RestaurantDetailProvider({required this.apiService,required this.database}) {
    _state = ResultState.loading; // Initialize _state in the constructor
  }


  late RestaurantDetailResponse _restaurantResponse;
  late ResultState _state;
  String _message = '';

  String? _id;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;


  String get message => _message;


  RestaurantDetailResponse get result => _restaurantResponse;

  ResultState get state => _state;

  Function(String,String,String) get postReview => _postReview;

  Future<void> checkFavorite(String restaurantId) async {
    var favorite = await database.getFavorite();
    bool isExist = false;
    favorite.forEach((element) {
      if(element.restaurantId == restaurantId){
        isExist = true;
      }
    });
    _isFavorite = isExist;
  }

  Future<void> addFavorite(String restaurantName,String restaurantId) async{
    await database.insertFavorite(restaurantName,restaurantId);
    _isFavorite = true;
    notifyListeners();
  }

  Future<void> deleteFavorite(String restaurantId) async{
    await database.deleteFavorite(restaurantId);
    _isFavorite = false;
    notifyListeners();
  }



  Future<dynamic> fetchRestaurantDetail(String id) async {
    print("saya");
    if(_id==null){
      _id = id; //berguna agar data dapat direfresh jika submit review
      print(id);
    }
    try {
      _state = ResultState.loading;
      notifyListeners();
      final isConnected = await checkInternet(InternetConnectionChecker());
      if(isConnected){
        final resto = await apiService.getDetail(id);
        if (resto.message == "Restaurant not found") {
          _state = ResultState.noData;
          notifyListeners();
          return _message = 'Empty Data';
        } else {
          _state = ResultState.hasData;
          await checkFavorite(resto.restaurant.id); //wajib await, krn kalau tidak await takutnya query ke db telat sehingga isfavorite di activity ga keupdate
          notifyListeners();
          _restaurantResponse = resto;
        }
      }
      else{
        _state = ResultState.noConnection;
        notifyListeners();
        return _message = 'No Network Available';
      }
    } catch (e) {
      print(e.toString());
      _state = ResultState.error;
      notifyListeners();
      return _message = 'Error --> $e';
    }
  }

  Future<dynamic> _postReview(String id,String name, String review) async{
    try{
      final isConnected = await checkInternet(InternetConnectionChecker());
      if(isConnected){
        var postResponse = await apiService.addReviews(id, name, review);
        if (postResponse.message=="success") {
          fetchRestaurantDetail(id);
        }
        else{
          print("gagal");
          print('gagal mengprint hasil data');
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
  // Simple check to see if we have Internet
  // ignore: avoid_print
  print('''The statement 'this machine is connected to the Internet' is: ''');
  final bool isConnected = await InternetConnectionChecker().hasConnection;
  print('hasil cek koneksi internet adalah :');
  // ignore: avoid_print
  print(isConnected.toString(),);
  return isConnected;
}