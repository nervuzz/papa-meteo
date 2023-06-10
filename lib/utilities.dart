import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import 'constants.dart';
import 'models.dart';

String getForecastPeriod() {
  var nowYYYYmmDD = DateFormat('yyyyMMdd').format(DateTime.now());
  var nowHH = int.parse(DateFormat('HH').format(DateTime.now()));
  // 00 - 3 AM and later
  // 06 - 10 AM and later
  // 12 - 3 PM and later
  // 18 - 9 PM and later
  if (nowHH >= 6 && nowHH < 13) {
    return "${nowYYYYmmDD}00";
  } else if (nowHH >= 13 && nowHH < 18) {
    return "${nowYYYYmmDD}06";
  } else if (nowHH >= 18 && nowHH < 24) {
    return "${nowYYYYmmDD}12";
  } else {
    // The lastest forecast from previous day
    // (nowHH >= 0 && nowHH < 6)
    return "${int.parse(nowYYYYmmDD) - 1}18";
  }
}

void changeToNextCity() async {
  var currentCityId;
  await HomeWidget.getWidgetData<int>('cityID', defaultValue: 0)
      .then((value) => currentCityId = value as int);
  currentCityId++;
  if (currentCityId == LIST_OF_CITIES.length) {
    currentCityId = 0;
  }
  await HomeWidget.saveWidgetData<int>('cityID', currentCityId);
}

// Called when doing background work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  var currentCityId;
  await HomeWidget.getWidgetData<int>('cityID', defaultValue: 0)
      .then((value) => currentCityId = value as int);
  changeToNextCity();
  var city = LIST_OF_CITIES.keys.toList()[currentCityId];
  var row = LIST_OF_CITIES.values.toList()[currentCityId].item1;
  var col = LIST_OF_CITIES.values.toList()[currentCityId].item2;
  var dt = DateFormat('yyyyMMdd HH:mm:ss').format(DateTime.now());
  var apiCallUrl = IcmApi(getForecastPeriod(), row, col).build();

  if (data?.host == 'cityclicked') {
    await HomeWidget.saveWidgetData<String>("widgetImg", apiCallUrl);
    await HomeWidget.saveWidgetData<String>('city', city);
    await HomeWidget.saveWidgetData<String>('dt', dt);
    await HomeWidget.updateWidget(
        name: 'HomeScreenWidgetProvider', iOSName: 'HomeScreenWidget');
  }
}
