import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatme.dart';

class MessagesListPage extends StatefulWidget {
  @override
  _MessagesListPageState createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages available.'));
          }

          final messages = snapshot.data!.docs;
          List<Widget> messageWidgets = messages.map((message) {
            final messageText = message['text'];
            final receiverEmail = message['receiver'];
            final _id = message['id'];

            return ListTile(
              title: Text(messageText),
              subtitle: Text('To: $receiverEmail'),
              onTap: () {
                // Navigate to the chat page with the receiver's email
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(receiverId: receiverEmail, id:_id ,),
                  ),
                );
              },
            );
          }).toList();

          return ListView(children: messageWidgets);
        },
      ),
    );
  }
}