import 'dart:io';
import 'package:chat_sotatek/emoji/emoticons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

var message = '', cursorPosition = 0;

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
  var textEditingController = new TextEditingController.fromValue(
    new TextEditingValue(
      text: message,
      selection: new TextSelection.collapsed(
        offset: cursorPosition,
      ),
    ),
  );

  String peerId;
  String peerAvatarUrl;
  String imageUrl;
  File imageFile;

  double marginBottomForEmojiKeyboard = 0;
  bool isKeyboardShowing = false;

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
  var keyboardVisibilityNoti, keyboardVisibilityNotiId;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    readLocal();
    keyboardVisibilityNoti = KeyboardVisibilityNotification();
    keyboardVisibilityNotiId =
        keyboardVisibilityNoti.addNewListener(onShow: () {
      _hideEmojiChooser();
      isKeyboardShowing = true;
    }, onHide: () {
      isKeyboardShowing = false;
    });
  }

  @override
  void dispose() {
    keyboardVisibilityNoti.removeListener(keyboardVisibilityNotiId);
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void onSendMessage(String content, String type) {
    if (content.trim() != '') {
      textEditingController.clear();
      var documentCurrentUser = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection('message')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      String groundChatPeerId = '$peerId-$currentUserId';

      var documentPeer = Firestore.instance
          .collection('messages')
          .document(groundChatPeerId)
          .collection('message')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentCurrentUser, {
          'content': content,
          'idFrom': currentUserId,
          'idTo': peerId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': type
        });
      });

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentPeer, {
          'content': content,
          'idFrom': currentUserId,
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

  Future getImage(ImageSource imageSource) async {
    imageFile = await ImagePicker.pickImage(source: imageSource);
    if (imageFile != null) {
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        onSendMessage(imageUrl, IMAGE_MESSAGE_TYPE);
      });
    });
  }

  Widget buidListMessage() {
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
    if (document['idFrom'] == currentUserId) {
      return Row(
        children: <Widget>[
          document['type'] == TEXT_MESSAGE_TYPE
              ? Container(
                  margin: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                  child: Text(
                    document['content'],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  width: 200.0,
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8.0)),
                )
              : Container(
                  margin: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                  child: CachedNetworkImage(
                    imageUrl: document['content'],
                    width: 200.0,
                    height: 200.0,
                    placeholder: CircularProgressIndicator(),
                  ),
                ),
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
                  width: 200.0,
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0)),
                )
              : Container(
                  margin: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                  child: CachedNetworkImage(
                    imageUrl: document['content'],
                    width: 200.0,
                    height: 200.0,
                    placeholder: CircularProgressIndicator(),
                  ),
                ),
        ],
      );
    }
  }

  Widget buildTextInput() {
    return Container(
      color: Colors.grey[200],
      child: Row(
        children: <Widget>[
          Container(
            child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.blue,
                ),
                onPressed: () {
                  getImage(ImageSource.camera);
                }),
          ),
          Container(
            child: IconButton(
                icon: Icon(
                  Icons.image,
                  color: Colors.blue,
                ),
                onPressed: () {
                  getImage(ImageSource.gallery);
                }),
          ),
          Flexible(
              child: Container(
            padding: EdgeInsets.only(left: 16.0),
            margin: EdgeInsets.all(8.0),
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.insert_emoticon,
                    color: Colors.blue,
                  ),
                  onPressed: _toggleEmojiChooser,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.black, fontSize: 15.0),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: textEditingController,
              focusNode: focusNode,
            ),
          )),
          Container(
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.blue,
              ),
              color: Colors.blue,
              onPressed: () {
                onSendMessage(textEditingController.text, 'text');
              },
            ),
          )
        ],
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
      body: new Stack(
        children: <Widget>[
          _buildEmojiChooser(),
          new Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: marginBottomForEmojiKeyboard,
            child: Column(
              children: <Widget>[
                buidListMessage(),
                buildTextInput(),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildEmojiChooser() {
    List<Container> containers =
        new List<Container>.generate(numberOfEmoji(), (int index) {
      Text textEmoji = new Text(getEmojiByIndex(index),
          style: new TextStyle(fontSize: 20.0));
      return new Container(
          margin: const EdgeInsets.all(2.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                _insertEmoji(textEmoji.data);
              },
              child: textEmoji,
            ),
          ));
    });

    return new Container(
      alignment: Alignment.bottomCenter,
      child: new Container(
        height: marginBottomForEmojiKeyboard,
        width: MediaQuery.of(context).size.width,
        child: new GridView.extent(
          maxCrossAxisExtent: MediaQuery.of(context).size.width / 7,
          children: containers,
        ),
      ),
    );
  }

  _insertEmoji(String emoji) {
    String textFieldData = textEditingController.text;
    var cursorOffset = textEditingController.selection;
    var cursorPosition = cursorOffset.baseOffset;
    var strWithEmoji;

    if (textFieldData.length > 0) {
      var tmpStringP1 = textFieldData.substring(0, cursorPosition);
      var tmpStringP2 = textFieldData.substring(cursorPosition);
      strWithEmoji = tmpStringP1 + emoji + tmpStringP2;
    } else {
      strWithEmoji = emoji;
    }
    setState(() {
      textEditingController = new TextEditingController.fromValue(
        new TextEditingValue(
          text: strWithEmoji,
          selection: new TextSelection.collapsed(
            offset: cursorPosition + emoji.length,
          ),
        ),
      );
    });
  }

  _hideEmojiChooser() {
    setState(() {
      marginBottomForEmojiKeyboard = 0;
    });
  }

  _toggleEmojiChooser() {
    setState(() {
      marginBottomForEmojiKeyboard == 0
          ? marginBottomForEmojiKeyboard = 200
          : marginBottomForEmojiKeyboard = 0;
    });
    if (isKeyboardShowing) {
      _hideKeyboard();
    }
  }

  _hideKeyboard() {
    focusNode.unfocus();
    var cursorPosition = textEditingController.selection.baseOffset;
    var textFieldData = textEditingController.text;
    setState(() {
      textEditingController = new TextEditingController.fromValue(
        new TextEditingValue(
          text: textFieldData,
          selection: new TextSelection.collapsed(
            offset: cursorPosition,
          ),
        ),
      );
    });
  }
}
