import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import 'constants.dart';
import 'models.dart';

/// Home screen widget - switch location by tapping on city name
void _changeToNextCity() async {
  var currentCityId;
  await HomeWidget.getWidgetData<int>('cityID', defaultValue: 0)
      .then((value) => currentCityId = value as int);
  currentCityId++;
  if (currentCityId == LIST_OF_CITIES.length) {
    currentCityId = 0;
  }
  await HomeWidget.saveWidgetData<int>('cityID', currentCityId);
}

/// Called when doing background work initiated from home screen widget
@pragma('vm:entry-point')
void backgroundCallback(Uri? data) async {
  var currentCityId;
  await HomeWidget.getWidgetData<int>('cityID', defaultValue: 0)
      .then((value) => currentCityId = value as int);
  _changeToNextCity();
  var city = LIST_OF_CITIES.keys.toList()[currentCityId];
  var row = LIST_OF_CITIES.values.toList()[currentCityId].item1;
  var col = LIST_OF_CITIES.values.toList()[currentCityId].item2;
  var dt = DateFormat('yyyyMMdd HH:mm:ss').format(DateTime.now());
  var apiCallUrl = IcmApi(row, col).build();

  if (data?.host == 'cityclicked') {
    await HomeWidget.saveWidgetData<String>('widgetImg', apiCallUrl);
    await HomeWidget.saveWidgetData<String>('city', city);
    await HomeWidget.saveWidgetData<String>('dt', dt);
    await HomeWidget.updateWidget(
        name: 'HomeScreenWidgetProvider', iOSName: 'HomeScreenWidget');
  }
}

/// Interaction with home screen widget
Future<void> sendAndUpdate(String location, String apiCallUrl) async {
  await _sendData(location, apiCallUrl);
  await _updateWidget();
}

Future _sendData(String location, String apiCallUrl) async {
  try {
    return Future.wait([
      HomeWidget.saveWidgetData<String>('widgetImg', apiCallUrl),
      HomeWidget.saveWidgetData<String>('city', location),
    ]);
  } on PlatformException catch (exception) {
    debugPrint('Error Sending Data. $exception');
  }
}

Future _updateWidget() async {
  try {
    return HomeWidget.updateWidget(
        name: 'HomeScreenWidgetProvider', iOSName: 'HomeScreenWidget');
  } on PlatformException catch (exception) {
    debugPrint('Error Updating Widget. $exception');
  }
}
