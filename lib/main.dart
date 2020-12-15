import 'dart:io' ;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gtaxi_app/screens/mainpage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
      appId: '1:297855924061:ios:c6de2b69b03a5be8',
      apiKey: 'AIzaSyCPVSNS03mulp7ZO-5FXtu6lv9ETU2jshY',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: '297855924061',
      databaseURL: 'https://gtaxi-de48c-default-rtdb.firebaseio.com',
    )
        : FirebaseOptions(
      appId: '1:678222681147:android:ba50fa6df415954848381e',
      apiKey: 'AIzaSyA5YMoap1vXN4vmihYc7-n0W3CF9pO3M30',
      messagingSenderId: '297855924061',
      projectId: 'flutter-firebase-plugins',
      databaseURL: 'https://gtaxi-de48c-default-rtdb.firebaseio.com',
    ),
  );
runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

