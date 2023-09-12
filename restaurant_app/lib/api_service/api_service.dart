import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/data/restaurant_response.dart';
import 'package:restaurant_app/data/review_response.dart';

import '../data/restaurant_detail_response.dart';


class ApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev';
  static const String _category = 'list';
  
  Future<RestaurantResponse> getAllList() async {
    final response = await http.get(Uri.parse("${_baseUrl}/$_category"));
    if (response.statusCode == 200) {
      print("sukses fetch api");
      return RestaurantResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<RestaurantDetailResponse> getDetail(String id) async {
      final response = await http.get(Uri.parse("${_baseUrl}/detail/$id"));
      if (response.statusCode == 200) {
        print("sukses fetch api");
        return RestaurantDetailResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load restaurant details');
      }
  }

  Future<RestaurantSearchResponse> getQueryRestaurant(String query) async {
    final response = await http.get(Uri.parse("${_baseUrl}/search?q=$query"));
    if (response.statusCode == 200) {
      print("sukses fetch api");
      return RestaurantSearchResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to search restaurants");
    }
  }

  Future<ReviewResponse> addReviews(String id,String name, String review) async {
    http.Response postResponse = await http.post(
      Uri.parse("${_baseUrl}/review"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': id,
        'name': name,
        'review': review
      }),
    );
    return ReviewResponse.fromJson(jsonDecode(postResponse.body));
  }
}