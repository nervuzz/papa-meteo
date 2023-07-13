import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

import 'constants.dart';

/// ICM meteograms URL builder
class IcmApi {
  static const String apiEndpoint =
      'https://www.meteo.pl/um/metco/mgram_pict.php';
  static const String forecastPeriodEndpoint =
      'http://meteo.icm.edu.pl/meteorogram_um_js.php';
  String lang;
  int row;
  int col;

  IcmApi(this.row, this.col, {this.lang = 'pl'});

  String build() {
    // var forecastPeriod = getForecastPeriodFromApi();
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
      // The latest forecast from previous day
      // (nowHH >= 0 && nowHH < 6)
      return '${int.parse(nowYYYYmmDD) - 1}18';
    }
  }

  /// Retrieve forecast period from auxiliary ICM API
  Future<String> getForecastPeriodFromApi() async {
    // Example of response's first line (split for clarity):
    //   var UM_YYYY=2023;var UM_MM=7;var UM_DD=11;var UM_ST=6;
    //   var UM_SYYYY="2023";var UM_SMM="07";var UM_SDD="11";
    //   var UM_SST="06";var UM_FULLDATE="2023071106";
    final response = await http.get(Uri.parse(forecastPeriodEndpoint));

    if (response.statusCode == 200) {
      String firstLine = response.body.split('\n').first;
      List<String> firstLineParts = firstLine.replaceAll('var ', '').split(';');
      String forecastPeriod = firstLineParts
          .firstWhere((_) => _.startsWith('UM_FULLDATE'))
          .replaceAll('"', '')
          .split('=')
          .last;

      return forecastPeriod;
    } else {
      // API not responding - figure forecast period manually
      return getForecastPeriod();
    }
  }
}

/// Manages application state
class MyAppState extends ChangeNotifier {
  static Tuple2 firstCity = LIST_OF_CITIES.entries.first.value;
  String dropdownValue = LIST_OF_CITIES.entries.first.key;
  int apiMeteoRow = firstCity.item1;
  int apiMeteoCol = firstCity.item2;
  String apiCallUrl = IcmApi(firstCity.item1, firstCity.item2).build();

  void justNotify() {
    // App state was updated outside
    notifyListeners();
  }

  void changeCity(String location) {
    dropdownValue = location;
    apiMeteoRow = LIST_OF_CITIES[location]!.item1;
    apiMeteoCol = LIST_OF_CITIES[location]!.item2;
    apiCallUrl = IcmApi(apiMeteoRow, apiMeteoCol).build();
    notifyListeners();
  }
}
