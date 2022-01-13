import 'package:flutter/material.dart';
import 'package:safe/screens/new_edit.dart';
import 'package:safe/screens/history.dart';
import 'package:safe/screens/home.dart';
import 'package:safe/screens/scan_ble.dart';
import 'package:safe/models/house_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomeScreen(title: 'Houses'),
        '/new': (context) => NewHouseScreen(),
        '/scan': (context) => ScanScreen(),
      },
    );
  }
}
