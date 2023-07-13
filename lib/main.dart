import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'preferences.dart';
import 'utilities.dart';
import 'widgets.dart';

/// Starting point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  initSharedPrefs();
  runApp(const MyApp());
}
