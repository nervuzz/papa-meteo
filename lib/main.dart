import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'title',
        'Updated from Background',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
      HomeWidget.updateWidget(
        name: 'HomeScreenWidgetProvider',
        iOSName: 'HomeScreenWidget',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  runApp(const MyApp());
}

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

const title = 'Papa Meteo';

const listOfCities = <String, Tuple2<int, int>>{
  // (Row, Col)
  'Kraków': Tuple2(466, 232),
  'Nawojowa': Tuple2(479, 247),
  'Łętownia': Tuple2(479, 234),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: title,
        home: MyHome(title: title),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // HomeWidget.registerBackgroundCallback(backgroundCallback);

  var forecastPeriod = getForecastPeriod();
  String dropdownValue = listOfCities.entries.first.key;
  static Tuple2 firstCity = listOfCities.entries.first.value;
  int apiMeteoRow = firstCity.item1;
  int apiMeteoCol = firstCity.item2;

  Future _sendData(String loc, String apiCallUrl) async {
    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('widgetImg', apiCallUrl),
        HomeWidget.saveWidgetData<String>('message', loc),
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

  Future<void> _sendAndUpdate(String loc, String apiCallUrl) async {
    await _sendData(loc, apiCallUrl);
    await _updateWidget();
  }

  void changeCity(String location) {
    forecastPeriod = getForecastPeriod();
    dropdownValue = location;
    apiMeteoRow = listOfCities[location]!.item1;
    apiMeteoCol = listOfCities[location]!.item2;
    var apiCallUrl =
        'https://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&fdate=${forecastPeriod}&row=${apiMeteoRow}&col=${apiMeteoCol}&lang=pl';
    notifyListeners();
    _sendAndUpdate(location, apiCallUrl);
  }
}

class MyHome extends StatelessWidget {
  const MyHome({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // log('[${appState.forecastPeriod}] Current city: ${appState.dropdownValue} [dropd: ${appState.dropdownValue}], Row: ${appState.apiMeteoRow}, Col: ${appState.apiMeteoCol}');
    var apiCallUrl =
        'https://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&fdate=${appState.forecastPeriod}&row=${appState.apiMeteoRow}&col=${appState.apiMeteoCol}&lang=pl';
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Image(
              image: AssetImage("assets/img/papa_icon.png"),
              width: 12,
              height: 12,
            );
          },
        ),
        title: Text(title),
        actions: <Widget>[
          DropdownButtonExample(),
        ],
      ),
      body: Center(
        child: CachedNetworkImage(
          placeholder: (context, url) => const CircularProgressIndicator(),
          imageUrl: apiCallUrl.toString(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Text("Coś tu kurła dam ${appState.forecastPeriod}"),
            Spacer(),
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = listOfCities.entries.first.key;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.sunny),
      elevation: 16,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      underline: Container(
        height: 0,
        // color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        appState.changeCity(value!);
        setState(() {
          dropdownValue = value;
        });
      },
      items: listOfCities.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
