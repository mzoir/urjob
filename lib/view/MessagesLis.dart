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
      setState(() {
        loggedInUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) {
      return const Center(child: Text('User not logged in.'));
    }

    final userEmail = loggedInUser!.email!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Messages'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!.docs;
          final filteredMessages = messages.where((message) {
            final sender = message['sender'];
            final receiver = message['receiver'];
            return sender == userEmail || receiver == userEmail;
          }).toList();

          if (filteredMessages.isEmpty) {
            return const Center(child: Text('No messages found.'));
          }

          return ListView.builder(
            itemCount: filteredMessages.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final message = filteredMessages[index];
              final receiver = message['receiver'];
              final sender = message['sender'];
              final _id = message['id'];
              final fullText = message['text'] ?? '';
              final lastLine = fullText.split('\n').last.trim();
              final otherUser = sender == userEmail ? receiver : sender;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade200,
                    child: Text(
                      otherUser[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    otherUser,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    lastLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(receiverId: otherUser, id: _id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
