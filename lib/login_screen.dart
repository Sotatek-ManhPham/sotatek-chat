import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_sotatek/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginScreen> {
  String titleButton = 'Sign in with Google';
  String message = "havanhung0402";

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn(BuildContext context) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    print('googleUser: $googleUser');
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    print('GoogleAuth: $googleAuth');
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(message: message,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
        child: Text('Login Page'),
      )),
      body: Center(
        child: FlatButton(
          child: Text(titleButton),
          color: Colors.red,
          textColor: Colors.white,
          onPressed: (){
            _handleSignIn(context);
          },
        ),
      ),
    );
  }
}
