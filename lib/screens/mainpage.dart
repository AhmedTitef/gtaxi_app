import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Page"),
      ),
      body: Center(
        child: MaterialButton(
          height: 50,
          minWidth: 300,
          color: Colors.green,
          onPressed: () {
            DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child("Test");
            databaseReference.set("isConnectedIOS");
          },
          child: Text("Text Connection"),
        ),
      ),
    );
  }
}