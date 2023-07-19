import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models.dart';
import 'preferences.dart';
import 'screens.dart';

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
          FavoriteLocationsDropdownButton(),
        ],
      ),
      body: Center(
        child: CachedNetworkImage(
          placeholder: (context, url) => const CircularProgressIndicator(),
          imageUrl: IcmApi(appState.apiMeteoRow, appState.apiMeteoCol).build(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Text('PL 🇵🇱'),
            Spacer(),
            Text(appState.dropdownValue),
            Spacer(),
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ListCityScreen()),
                  );
                }),
            IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoriteLocationsScreen()),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class FavoriteLocationsDropdownButton extends StatefulWidget {
  const FavoriteLocationsDropdownButton({super.key});

  @override
  State<FavoriteLocationsDropdownButton> createState() =>
      _FavoriteLocationsDropdownButtonState();
}

class _FavoriteLocationsDropdownButtonState
    extends State<FavoriteLocationsDropdownButton> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return FutureBuilder<List<String>>(
      future: getFavorites(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          String aValue;
          List<DropdownMenuItem<String>> aItems;
          if (snapshot.data!.isNotEmpty) {
            aValue = snapshot.data!.first;
            aItems =
                snapshot.data!.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList();
          } else {
            aValue = '';
            aItems = [
              DropdownMenuItem<String>(
                  value: aValue, child: Text('No favorites 😢')),
            ];
          }
          return DropdownButton<String>(
            value: aValue,
            elevation: 16,
            style: const TextStyle(color: Colors.black, fontSize: 19),
            underline: Container(
              height: 0,
            ),
            onChanged: (String? value) {
              appState.changeCity(value!);
            },
            items: aItems,
          );
        }
        return Container();
      },
    );
  }
}
