// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/api_service/api_service.dart';

import 'package:restaurant_app/main.dart';
import 'package:restaurant_app/provider/restaurant_provider.dart';

void main() {
  test('parsing json success', () async {
    var restaurantProvider = RestaurantProvider(apiService: ApiService());

    await restaurantProvider.fetchAllRestaurant();

    var result = restaurantProvider.result.isNotEmpty;
    expect(result, true);

  });
}
