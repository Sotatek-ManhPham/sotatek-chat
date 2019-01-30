import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_sotatek/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  _HomeScreenState({Key key, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Home"),
              centerTitle: true,
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
      );
    }
  }
}
