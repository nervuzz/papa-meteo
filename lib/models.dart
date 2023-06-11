import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

import 'constants.dart';
import 'utilities.dart';

/// ICM meteograms URL builder
class IcmApi {
  static const String apiEndpoint =
      'https://www.meteo.pl/um/metco/mgram_pict.php';
  String lang;
  int row;
  int col;

  IcmApi(this.row, this.col, {this.lang = 'pl'});

  String build() {
    var forecastPeriod = getForecastPeriod();
    return '$apiEndpoint?ntype=0u&fdate=$forecastPeriod&row=$row&col=$col&lang=$lang';
  }

  /// Forecasts are published at regular hours so we can figure out the
  /// current one basing on local time. Below logic is not timezone-aware!
  String getForecastPeriod() {
    var now = DateTime.now();
    var nowYYYYmmDD = DateFormat('yyyyMMdd').format(now);
    var nowHH = int.parse(DateFormat('HH').format(now));

    if (nowHH >= 6 && nowHH < 13) {
      return '${nowYYYYmmDD}00';
    } else if (nowHH >= 13 && nowHH < 18) {
      return '${nowYYYYmmDD}06';
    } else if (nowHH >= 18 && nowHH < 24) {
      return '${nowYYYYmmDD}12';
    } else {
      // The lastest forecast from previous day
      // (nowHH >= 0 && nowHH < 6)
      return '${int.parse(nowYYYYmmDD) - 1}18';
    }
  }
}

/// Manages application state
class MyAppState extends ChangeNotifier {
  static Tuple2 firstCity = LIST_OF_CITIES.entries.first.value;
  String dropdownValue = LIST_OF_CITIES.entries.first.key;
  int apiMeteoRow = firstCity.item1;
  int apiMeteoCol = firstCity.item2;

  void changeCity(String location) {
    dropdownValue = location;
    apiMeteoRow = LIST_OF_CITIES[location]!.item1;
    apiMeteoCol = LIST_OF_CITIES[location]!.item2;

    var apiCallUrl = IcmApi(apiMeteoRow, apiMeteoCol).build();
    notifyListeners();
    sendAndUpdate(location, apiCallUrl);
  }
}
