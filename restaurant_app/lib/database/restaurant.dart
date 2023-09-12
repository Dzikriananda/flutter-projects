
class RestaurantSQLite{
  late String restaurantName;
  late String restaurantId;

  RestaurantSQLite({required this.restaurantName,required this.restaurantId});

  RestaurantSQLite.fromMap(Map<String,dynamic> map){
      restaurantName = map['restaurant_name'];
      restaurantId = map['restaurant_id'];
  }

  Map<String,dynamic> toMap(){
    return {'restaurant_name' : restaurantName,'restaurant_id': restaurantId};
  }


}