import 'package:chat_sotatek/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_sotatek/chat_screen.dart';
import 'package:chat_sotatek/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _HomeScreenState createState() {
    return _HomeScreenState(currentUserId: currentUserId);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final String currentUserId;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  _HomeScreenState({Key key, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Home",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text("Home"),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: SearchScreen());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: _handleSignout,
                ),
              ],
            ),
            body: StreamBuilder(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    itemBuilder: (context, index) =>
                        buildItem(context, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                  );
                }
              },
            )));
  }

  Future _handleSignout() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false);
  }

  Widget buildItem(BuildContext context, document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return ListTile(
        leading: Material(
          child: CachedNetworkImage(
            placeholder: CircularProgressIndicator(),
            imageUrl: document['photoUrl'],
            width: 48.0,
            height: 48.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
          clipBehavior: Clip.hardEdge,
        ),
        title: Text(document['nickname']),
        subtitle: Text('You: Happy new year'),
        onTap: () {
          _showChat(document.documentID, document['photoUrl']);
        },
      );
    }
  }

  _showChat(String peerId, String avatarUrl) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(peerId: peerId, peerAvatarUrl: avatarUrl)));
  }
}
