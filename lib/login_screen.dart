import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_sotatek/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (user != null) {
      print(user);
      final QuerySnapshot userQuery = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = userQuery.documents;
      print(documents);
      if (documents.length == 0) {
        Firestore.instance.collection('users').document(user.uid).setData(
            {'nickname': user.displayName, 'photoUrl': user.photoUrl, 'id': user.uid});
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  message: message,
                )));
    return user;
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
          onPressed: () {
            _handleSignIn(context);
          },
        ),
      ),
    );
  }
}
