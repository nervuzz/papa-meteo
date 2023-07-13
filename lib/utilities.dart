import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import 'constants.dart';
import 'models.dart';
import 'preferences.dart';

/// Home screen widget - switch location by tapping on city name
void changeToNextCity() async {
  debugPrint('changeToNextCity: start');
  var currentCityId;
  List<String> userFavs = await userFavoriteLocations();
  await HomeWidget.getWidgetData<int>('cityID', defaultValue: 0)
      .then((value) => currentCityId = value as int);
  currentCityId++;
  if (currentCityId == userFavs.length) {
    currentCityId = 0;
  }
  await HomeWidget.saveWidgetData<int>('cityID', currentCityId);
  await HomeWidget.saveWidgetData<String>('city', userFavs.first);
  await HomeWidget.updateWidget(name: 'HomeScreenWidgetProvider');
  debugPrint('changeToNextCity: end');
}

/// Called when doing background work initiated from home screen widget
@pragma('vm:entry-point')
void backgroundCallback(Uri? data) async {
  debugPrint('backgroundCallback: $data');
  var currentCityId;
  List<String> userFavs = await userFavoriteLocations();
  await HomeWidget.getWidgetData<int>('cityID', defaultValue: 0)
      .then((value) => currentCityId = value as int);
  // _changeToNextCity();
  var city = userFavs[currentCityId];
  var row = LIST_OF_CITIES[city]!.item1;
  var col = LIST_OF_CITIES[city]!.item2;
  // var dt = DateFormat('yyyyMMdd HH:mm:ss').format(DateTime.now());
  var apiCallUrl = IcmApi(row, col).build();
  sendAndUpdate(city, apiCallUrl);
  // if (data?.host == 'nextCity') {
  //   await HomeWidget.saveWidgetData<String>('widgetImg', apiCallUrl);
  //   await HomeWidget.saveWidgetData<String>('city', city);
  //   await HomeWidget.saveWidgetData<String>('dt', dt);
  //   await HomeWidget.updateWidget(name: 'HomeScreenWidgetProvider');
  // }

  // if (data?.host == 'refreshDataIntent') {
  //   await HomeWidget.saveWidgetData<String>('widgetImg', apiCallUrl);
  //   await HomeWidget.saveWidgetData<String>('city', city);
  //   await HomeWidget.saveWidgetData<String>('dt', dt);
  //   await HomeWidget.updateWidget(name: 'HomeScreenWidgetProvider');
  // }
}

/// Interaction with home screen widget
Future<void> sendAndUpdate(String location, String apiCallUrl) async {
  debugPrint('sendAndUpdate start');
  await _sendData(location, apiCallUrl);
  await updateWidget();
  debugPrint('sendAndUpdate end');
}

Future _sendData(String location, String apiCallUrl) async {
  try {
    var dt = DateFormat('yyyyMMdd HH:mm:ss').format(DateTime.now());
    return Future.wait([
      HomeWidget.saveWidgetData<String>('widgetImg', apiCallUrl),
      HomeWidget.saveWidgetData<String>('city', location),
      HomeWidget.saveWidgetData<String>('dt', dt),
    ]);
  } on PlatformException catch (exception) {
    debugPrint('Error Sending Data. $exception');
  }
  debugPrint('_sendData end');
}

Future updateWidget() async {
  try {
    return HomeWidget.updateWidget(name: 'HomeScreenWidgetProvider');
  } on PlatformException catch (exception) {
    debugPrint('Error Updating Widget. $exception');
  }
  debugPrint('_updateWidget end');
}
