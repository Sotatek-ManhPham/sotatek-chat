import 'package:chat_sotatek/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return _buildResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return _buildSuggestion();
  }

  Widget _buildSuggestion() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .where('nickname', isEqualTo: query)
          .snapshots(),
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
    );
  }

  Widget buildItem(BuildContext context, document) {
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
      onTap: () {
        _showChat(context, document.documentID, document['photoUrl']);
      },
    );
  }

  _showChat(BuildContext context, String peerId, String avatarUrl) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(peerId: peerId, peerAvatarUrl: avatarUrl)));
  }

  Widget _buildResults() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .where('nickname', isEqualTo: query)
          .snapshots(),
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
    );
  }
}
