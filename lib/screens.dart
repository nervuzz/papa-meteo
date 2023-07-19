import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models.dart';
import 'preferences.dart';

class ListCityScreen extends StatelessWidget {
  const ListCityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Select city'),
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 3),
          children: LIST_OF_CITIES.keys.map<ListTile>((String value) {
            return ListTile(
              title: Text(value),
              onTap: () {
                appState.changeCity(value);
                Navigator.pop(context); // Return to main menu
              },
              onLongPress: () {
                markFavorite(value);
                appState.justNotify();
                _showToast(context, value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String value) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$value added to 💓'),
      ),
    );
  }
}

class FavoriteLocationsScreen extends StatelessWidget {
  const FavoriteLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return FutureBuilder<List<String>>(
      future: getFavorites(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          List<ListTile> aItems;
          if (snapshot.data!.isNotEmpty) {
            aItems = snapshot.data!.map<ListTile>((String value) {
              return ListTile(
                title: Text(value),
                onTap: () {
                  unmarkFavorite(value);
                  appState.justNotify();
                  _showToast(context, value);
                },
              );
            }).toList();
          } else {
            aItems = <ListTile>[];
          }
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('Favorite Locations'),
            ),
            body: Scrollbar(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: aItems,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  void _showToast(BuildContext context, String value) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$value disliked 💘'),
      ),
    );
  }
}
