import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'utilities.dart';
import 'widgets.dart';

/// Starting point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(const MyApp());
}
