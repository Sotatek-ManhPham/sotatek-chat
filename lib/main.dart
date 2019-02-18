import 'package:chat_sotatek/src/controller/Controller.dart';
import 'package:chat_sotatek/src/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

void main() => runApp(MyApp());

class MyApp extends AppMVC {

  static final Controller sController = Controller();

  MyApp({Key key}) : super(con: sController, key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sotatek Chat',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
