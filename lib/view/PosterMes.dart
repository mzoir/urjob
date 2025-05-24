import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat.dart';
import 'chatme.dart';

class MessagePo extends StatefulWidget {
  @override
  _MessagePoState createState() => _MessagePoState();
}

class _MessagePoState extends State<MessagePo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('conversations')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allConversations = snapshot.data!.docs;

          final userConversations = allConversations.where((doc) {
            final users = List<String>.from(doc['users'] ?? []);
            return users.contains(currentUserEmail);
          }).toList();

          if (userConversations.isEmpty) {
            return const Center(child: Text('No conversations found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: userConversations.length,
            itemBuilder: (context, index) {
              final conversation = userConversations[index];
              final users = List<String>.from(conversation['users']);
              final timestamp = conversation['timestamp'] as Timestamp;
              final conversationId = conversation.id;
              final otherUser = users.firstWhere((u) => u != currentUserEmail);

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .where('id', isEqualTo: conversationId)
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  String lastMessageText = 'No message yet';
                  if (messageSnapshot.hasData &&
                      messageSnapshot.data!.docs.isNotEmpty) {
                    final lastMessageDoc = messageSnapshot.data!.docs.first;
                    final fullText = lastMessageDoc['text'] ?? '';
                    final parts = fullText.split('\n');
                    lastMessageText = parts.isNotEmpty ? parts.last.trim() : '';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      title: Text(
                        otherUser,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                      subtitle: Text(
                        lastMessageText,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatTimestamp(timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              receiverId: otherUser,
                              id: conversationId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}
