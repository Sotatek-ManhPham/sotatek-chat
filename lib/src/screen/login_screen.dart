import 'package:chat_sotatek/localizations.dart';
import 'package:chat_sotatek/src/controller/Controller.dart';
import 'package:chat_sotatek/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:chat_sotatek/src/screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginScreen> {
  final Controller controller = Controller.sController;

  User user;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller.isLoggedIn().then((isLoggedIn){
      if(isLoggedIn){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    currentUser: user,
                  )));
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    controller.getCurrentUser().then((currentUser) {
      setState(() {
        user = currentUser;
      });
    });
    return Scaffold(
        appBar: AppBar(
            title: Center(
          child: Text(AppLocalizations.of(context).textLoginButtonGoogle),
        )),
        body: Stack(
          children: <Widget>[
            Center(
              child: FlatButton(
                child: Text('Sign in with Google'),
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () {
                  controller.loginGoogle().then((user){
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              currentUser: user,
                            )));
                  });

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
