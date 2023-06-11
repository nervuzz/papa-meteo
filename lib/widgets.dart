import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models.dart';

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
    var apiCallUrl = IcmApi(appState.apiMeteoRow, appState.apiMeteoCol).build();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Image(
              image: AssetImage('assets/img/home_icon.png'),
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
          imageUrl: apiCallUrl,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Text('PL 🇵🇱'),
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
