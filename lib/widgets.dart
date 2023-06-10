import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'constants.dart';
import 'models.dart';
import 'utilities.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: APP_TITLE,
        home: MyHome(title: APP_TITLE),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  static Tuple2 firstCity = LIST_OF_CITIES.entries.first.value;
  var forecastPeriod = getForecastPeriod();
  String dropdownValue = LIST_OF_CITIES.entries.first.key;
  int apiMeteoRow = firstCity.item1;
  int apiMeteoCol = firstCity.item2;

  void changeCity(String location) {
    dropdownValue = location;
    apiMeteoRow = LIST_OF_CITIES[location]!.item1;
    apiMeteoCol = LIST_OF_CITIES[location]!.item2;

    var apiCallUrl =
        IcmApi(getForecastPeriod(), apiMeteoRow, apiMeteoCol).build();
    notifyListeners();
    _sendAndUpdate(location, apiCallUrl);
  }

  Future<void> _sendAndUpdate(String loc, String apiCallUrl) async {
    await _sendData(loc, apiCallUrl);
    await _updateWidget();
  }

  Future _sendData(String loc, String apiCallUrl) async {
    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('widgetImg', apiCallUrl),
        HomeWidget.saveWidgetData<String>('city', loc),
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
}

class MyHome extends StatelessWidget {
  final String title;

  const MyHome({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // log('[${appState.forecastPeriod}] Current city: ${appState.dropdownValue} [dropd: ${appState.dropdownValue}], Row: ${appState.apiMeteoRow}, Col: ${appState.apiMeteoCol}');
    var apiCallUrl = IcmApi(
            appState.forecastPeriod, appState.apiMeteoRow, appState.apiMeteoCol)
        .build();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Image(
              image: AssetImage("assets/img/home_icon.png"),
              width: 12,
              height: 12,
            );
          },
        ),
        title: Text(title),
        actions: <Widget>[
          PickCityDropdownButton(),
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

class PickCityDropdownButton extends StatefulWidget {
  const PickCityDropdownButton({super.key});

  @override
  State<PickCityDropdownButton> createState() => _PickCityDropdownButtonState();
}

class _PickCityDropdownButtonState extends State<PickCityDropdownButton> {
  String dropdownValue = LIST_OF_CITIES.entries.first.key;

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
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item
        appState.changeCity(value!);
        setState(() {
          dropdownValue = value;
        });
      },
      items: LIST_OF_CITIES.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
