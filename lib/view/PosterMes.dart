import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chatme.dart';

class MessagePo extends StatefulWidget {
  @override
  _MessagePoState createState() => _MessagePoState();
}

class _MessagePoState extends State<MessagePo> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail = _auth.currentUser?.email;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserEmail == null) {
      return const Center(child: Text('Not logged in.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Conversations')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversations.'));
          }

          final messages = snapshot.data!.docs;

          // Only keep the latest message for each conversation
          final Map<String, QueryDocumentSnapshot> latestMessages = {};

          for (var msg in messages) {
            final chatId = msg['id'];
            final sender = msg['sender'];
            final receiver = msg['receiver'];

            if (sender == currentUserEmail || receiver == currentUserEmail) {
              if (!latestMessages.containsKey(chatId)) {
                latestMessages[chatId] = msg;
              }
            }
          }

          final conversationWidgets = latestMessages.entries.map((entry) {
            final msg = entry.value;
            final chatId = msg['id'];
            final lastText = msg['text'];
            final sender = msg['sender'];
            final receiver = msg['receiver'];
            final otherUser = currentUserEmail == sender ? receiver : sender;

            return ListTile(
              title: Text(otherUser),
              subtitle: Text(lastText),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(receiverId: otherUser, id: chatId),
                  ),
                );
              },
            );
          }).toList();

          return ListView(children: conversationWidgets);
        },
      ),
    );
  }
}
