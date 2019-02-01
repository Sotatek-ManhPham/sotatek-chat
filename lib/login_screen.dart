import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_sotatek/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser currentUser;
  SharedPreferences prefs;
  bool isLoading = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() => isLoading = true);
    prefs = await SharedPreferences.getInstance();
    isLoggedIn = await _googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    currentUserId: prefs.getString('id'),
                  )));
    }
    this.setState(() => isLoading = false);
  }

  Future<FirebaseUser> _handleSignIn(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    this.setState(() => isLoading = true);

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    if (user != null) {
      final QuerySnapshot userQuery = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = userQuery.documents;
      if (documents.length == 0) {
        Firestore.instance.collection('users').document(user.uid).setData({
          'nickname': user.displayName,
          'photoUrl': user.photoUrl,
          'id': user.uid
        });
        currentUser = user;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
      }


      this.setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    currentUserId: user.uid,
                  )));
    } else {
      this.setState(() {
        isLoading = false;
      });
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Center(
          child: Text('Login Page'),
        )),
        body: Stack(
          children: <Widget>[
            Center(
              child: FlatButton(
                child: Text('Sign in with Google'),
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () {
                  _handleSignIn(context);
                },
              ),
            ),
            Positioned(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container())
          ],
        ));
  }
}
