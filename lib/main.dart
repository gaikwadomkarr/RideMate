import 'package:bikingapp/LoginPage1.dart';
import 'package:bikingapp/ProfilePage.dart';
import 'package:bikingapp/SignUpPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [NavigatorObserver()],
      home: LoginPage1(),
    );
  }
}
