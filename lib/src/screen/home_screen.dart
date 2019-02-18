import 'package:chat_sotatek/src/controller/Controller.dart';
import 'package:chat_sotatek/src/model/user.dart';
import 'package:chat_sotatek/src/screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_sotatek/src/screen/chat_screen.dart';
import 'package:chat_sotatek/src/screen/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;

  HomeScreen({Key key, @required this.currentUser}) : super(key: key);

  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  Controller controller = Controller.sController;

  _HomeScreenState({Key key});

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
              stream: controller.getSnapshotsUser(),
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

  void _handleSignout() {
    controller.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false);
  }

  Widget buildItem(BuildContext context, document) {
    if (document['id'] == widget.currentUser.id) {
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
          User user = User(id: document.documentID, avatarUrl: document['photoUrl'], nickName: document['nickname']);
          _showChat(user);
        },
      );
    }
  }

  _showChat(User user) {

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(peerUser: user, currentUser: widget.currentUser)));
  }
}
