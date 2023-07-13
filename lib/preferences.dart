import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utilities.dart';

/// Initialize shared application settings store
Future<void> initSharedPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // <START> User's favorite locations
  final List<String> favoriteLocations =
      prefs.getStringList('favoriteLocations') ?? <String>['Kraków'];
  prefs.setStringList('favoriteLocations', favoriteLocations);
  changeToNextCity();
  debugPrint("initSharedPrefs end (change + call)");
  // <END> User's favorite locations
}

/// Get favorite city (location) list
Future<List<String>> getFavorites() async {
  List<String>? favoriteLocations = (await SharedPreferences.getInstance())
      .getStringList('favoriteLocations');
  return favoriteLocations!;
}

/// Add city (location) to favorites list
Future<void> markFavorite(String location) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? favoriteLocations = prefs.getStringList('favoriteLocations');
  Set<String> _set = favoriteLocations!.toSet();
  _set.add(location);
  prefs.setStringList('favoriteLocations', _set.toList());
  debugPrint("markFavorite: $location");
}

/// Remove city (location) from favorites list
Future<void> unmarkFavorite(String location) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? favoriteLocations = prefs.getStringList('favoriteLocations');
  favoriteLocations!.remove(location);
  prefs.setStringList('favoriteLocations', favoriteLocations);
  debugPrint("unmarkFavorite: $location");
}

Future<List<String>> userFavoriteLocations() async {
  List<String> userFavs = await getFavorites();
  return userFavs;
}
