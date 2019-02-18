import 'dart:io';

import 'package:chat_sotatek/src/model/user.dart';
import 'package:chat_sotatek/src/model/Model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc_pattern/mvc_pattern.dart' show ControllerMVC;
class Controller extends ControllerMVC {

  static Controller sController;
  Controller._();
  factory Controller() {
    if (sController == null) sController = Controller._();
    return sController;
  }

  static final sUserModel = UserModel();

  Future<User> loginGoogle(){
    return sUserModel.loginGoogle();
  }

  Future<User> getCurrentUser() {
    return sUserModel.getCurrentUser();
  }

  Future<bool> isLoggedIn() {
    return sUserModel.isLoggedIn();
  }

  void signOut() {
    sUserModel.signOut();
  }

//  List<User> getUsers() {
//    return sUserModel.getUsers();
//  }

  Stream<QuerySnapshot> getSnapshotsUser() {
    return sUserModel.getSnapshotsUser();
  }

  void saveMessage(String content, String type, User currentUser, User peerUser) {
    sUserModel.saveMessage(content, type, currentUser, peerUser);
  }

  void uploadImage(File imageFile, String type, User currentUser, User peerUser){
    sUserModel.uploadImage(imageFile, type, currentUser, peerUser);
  }

  Stream<QuerySnapshot> getSnapshotsMessage(String groupChatId) {
    return sUserModel.getSnapshotsMessage(groupChatId);
  }

  Stream<QuerySnapshot> findSnapshotsUser(String query) {
    return sUserModel.findSnapshotsUser(query);
  }
}