import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{

  String message;

  HomeScreen({@required this.message});

  @override
  _HomeScreenState createState() {
    return _HomeScreenState(message);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String message;

  _HomeScreenState(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Text(message)
    );
  }
}