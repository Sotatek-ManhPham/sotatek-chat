import 'package:chat_sotatek/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_sotatek/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sotatek Chat',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home' : (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

