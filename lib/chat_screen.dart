import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatarUrl;

  ChatScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatarUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(
        peerId: peerId,
        peerAvatarUrl: peerAvatarUrl,
      );
}

class _ChatScreenState extends State<ChatScreen> {
  final FocusNode focusNode = new FocusNode();
  final String TEXT_MESSAGE_TYPE = 'text';
  final String IMAGE_MESSAGE_TYPE = 'image';
  final TextEditingController textEditingController =
      new TextEditingController();

  String peerId;
  String peerAvatarUrl;
  String id;

  _ChatScreenState({
    Key key,
    @required this.peerId,
    @required this.peerAvatarUrl,
  });

  bool isShowSticker;
  SharedPreferences prefs;
  String currentUserId;
  String groupChatId;
  String photoUrlCurrentUser;
  var listMessage;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection('message')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentReference, {
          'content': content,
          'idFrom': id,
          'idTo': peerId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': type
        });
      });
    }
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('id');
    photoUrlCurrentUser = prefs.getString('photoUrl') ?? '';
    groupChatId = '$currentUserId-$peerId';
    setState(() {});
  }

  Widget buidListMessage() {
    print('groupChatId: ${groupChatId}');
    return Flexible(
        child: groupChatId == ''
            ? Center(child: CircularProgressIndicator())
            : StreamBuilder(
                stream: Firestore.instance
                    .collection('messages')
                    .document(groupChatId)
                    .collection('message')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    listMessage = snapshot.data.documents;
                    print('List message: $listMessage');
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: listMessage.length,
                      itemBuilder: (context, index) =>
                          buildItem(index, listMessage[index]),
                      reverse: true,
                    );
                  }
                },
              ));
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    print('idFrom: ${document['idFrom']}');
    print('Current id: $currentUserId');
    print('Chat current user: ${document['idFrom'] == currentUserId}');
    if (document['idFrom'] == currentUserId) {
      return Row(
        children: <Widget>[
          document['type'] == TEXT_MESSAGE_TYPE
              ? Container(
                  margin: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                  child: Text(
                    document['content'],
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0)),
                )
              : Text('image'),
          Material(
            child: CachedNetworkImage(
              imageUrl: photoUrlCurrentUser,
              width: 24,
              height: 24,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            clipBehavior: Clip.hardEdge,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return Row(
        children: <Widget>[
          Material(
            child: CachedNetworkImage(
              imageUrl: peerAvatarUrl,
              width: 24,
              height: 24,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            clipBehavior: Clip.hardEdge,
          ),
          document['type'] == TEXT_MESSAGE_TYPE
              ? Container(
                  margin: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                  child: Text(
                    document['content'],
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0)),
                )
              : Text('image'),
        ],
      );
    }
  }

  Widget buildTextInput() {
    return Container(
      height: 48.0,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: TextField(
        style: TextStyle(color: Colors.black, fontSize: 15.0),
        controller: textEditingController,
        focusNode: focusNode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            buidListMessage(),
            buildTextInput(),
          ],
        ));
  }
}
