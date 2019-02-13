import 'dart:io';

import 'package:chat_sotatek/src/controller/Controller.dart';
import 'package:chat_sotatek/src/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {

  Future<User> loginGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser currentUser = await _auth.signInWithCredential(credential);
    User user = User(id: currentUser.uid, nickName: currentUser.displayName, avatarUrl: currentUser.photoUrl);
    if (currentUser != null) {
      final QuerySnapshot userQuery = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: currentUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = userQuery.documents;
      if (documents.length == 0) {
        Firestore.instance.collection('users').document(currentUser.uid).setData({
          'nickname': currentUser.displayName,
          'photoUrl': currentUser.photoUrl,
          'id': currentUser.uid
        });
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
      }
    }
    return user;
  }

  Future<bool> isLoggedIn() async{
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    bool isLoggedIn = await _googleSignIn.isSignedIn();
    return isLoggedIn;
  }

  Future<User> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return User(id: prefs.getString('id'),
        nickName: prefs.getString('nickname'),
        avatarUrl: prefs.getString('photoUrl'));
  }

  Future signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }

  Stream<QuerySnapshot> getSnapshotsUser() {
    return Firestore.instance.collection('users').snapshots();
  }

  void saveMessage(String content, String type, User currentUser, User peerUser) {
    String groupChatId = '${currentUser.id}-${peerUser.id}';
    if (content.trim() != '') {
      var documentCurrentUser = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection('message')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      String groundChatPeerId = '${peerUser.id}-${currentUser.id}';

      var documentPeer = Firestore.instance
          .collection('messages')
          .document(groundChatPeerId)
          .collection('message')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentCurrentUser, {
          'content': content,
          'idFrom': currentUser.id,
          'idTo': peerUser.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': type
        });
      });

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentPeer, {
          'content': content,
          'idFrom': currentUser.id,
          'idTo': peerUser.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': type
        });
      });
    }
  }

  Future uploadImage(File imageFile, String type, User currentUser, User peerUser) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
       saveMessage(downloadUrl, type, currentUser, peerUser);
    });
  }

  Stream<QuerySnapshot> getSnapshotsMessage(String groupChatId) {
    return Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection('message')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> findSnapshotsUser(String query) {
    return Firestore.instance
        .collection('users')
        .where('nickname', isEqualTo: query)
        .snapshots();
  }

//  List<User> getUsers() {
//    List<User> users = List();
//    Stream<QuerySnapshot> snapshots = Firestore.instance.collection('users').snapshots();
//    snapshots.listen((querySnapshot){
//      querySnapshot.documents.forEach((data){
//        print(data['nickname']);
//        users.add(User(id: 'dasd', nickName: 'asdsa', avatarUrl: 'asdasd'));
//        return users;
//      });
//    });
//    print(users);
//    return users;
//  }
}
