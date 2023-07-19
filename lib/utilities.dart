import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import 'constants.dart';
import 'models.dart';
import 'preferences.dart';

/// Home screen widget - switch location by tapping on city label
void changeToNextCity() async {
  List<String> userFavs = await getFavorites();
  int currentCityId =
      await HomeWidget.getWidgetData<int>('cityID', defaultValue: 0) as int;
  currentCityId = currentCityId >= userFavs.length - 1 ? 0 : currentCityId + 1;
  String city = userFavs.elementAt(currentCityId);
  int row = LIST_OF_CITIES[city]!.item1;
  int col = LIST_OF_CITIES[city]!.item2;
  String apiCallUrl = IcmApi(row, col).build();
  return sendAndUpdate(city, apiCallUrl, currentCityId);
}

/// Home screen widget - get most recent forecast by tapping on time label
void updateForecast(String currentCity) async {
  int row = LIST_OF_CITIES[currentCity]!.item1;
  int col = LIST_OF_CITIES[currentCity]!.item2;
  String apiCallUrl = IcmApi(row, col).build();
  return sendAndUpdate(currentCity, apiCallUrl);
}

/// Called when doing background work initiated from home screen widget
@pragma('vm:entry-point')
void backgroundCallback(Uri? data) async {
  switch (data!.host) {
    case 'nextcity':
      changeToNextCity();
    case 'updateforecast':
      updateForecast(Uri.decodeComponent(data.fragment));
  }
}

/// Interaction with home screen widget
Future<void> sendAndUpdate(String city, String apiCallUrl,
    [int? cityId]) async {
  await _sendData(city, apiCallUrl, cityId);
  await _updateWidget();
}

Future _sendData(String city, String apiCallUrl, [int? cityId]) async {
  try {
    List<Future<bool?>> listOfFutures = [
      HomeWidget.saveWidgetData<String>('widgetImg', apiCallUrl),
      HomeWidget.saveWidgetData<String>('city', city),
    ];
    if (cityId != null) {
      listOfFutures.add(HomeWidget.saveWidgetData<int>('cityID', cityId));
    }
    return Future.wait(listOfFutures);
  } on PlatformException catch (exception) {
    debugPrint('Error sending data. $exception');
  }
}

Future _updateWidget() async {
  try {
    return HomeWidget.updateWidget(name: 'HomeScreenWidgetProvider');
  } on PlatformException catch (exception) {
    debugPrint('Error updating widget. $exception');
  }
}
