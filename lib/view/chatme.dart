import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String? id; // Message ID (nullable)

  ChatPage({required this.receiverId, this.id});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
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
  void sendMessage() async {
    if (_controller.text.isNotEmpty) {
      // Use the provided ID or generate a new one if it's null or empty
      String messageId = widget.id?.isNotEmpty == true ? widget.id! : _firestore.collection('messages').doc().id;

      try {
        DocumentSnapshot messageDoc = await _firestore.collection('messages').doc(messageId).get();

        if (!messageDoc.exists) {
          final user = _auth.currentUser;
          // Create a new message document if it doesn't exist
          await _firestore.collection('messages').doc(messageId).set({
            'text': "${_controller.text}: ${user?.email}",
            'sender': loggedInUser?.email,
            'receiver': widget.receiverId,
            'id': messageId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          // If the document exists, retrieve the existing text and append the new message
          String existingText = messageDoc['text'];
          String updatedText = existingText + '\n' + _controller.text; // Append new message
          final user = _auth.currentUser;
          await _firestore.collection('messages').doc(messageId).set({
            'text': "${updatedText}: ${user?.email}",
            'sender': loggedInUser?.email,
            'receiver': widget.receiverId,
            'id': messageId,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // Merge to keep existing messages
        }

        _controller.clear();
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                // Filter messages based on the provided ID
                final filteredMessages = messages.where((message) {
                  return message['id'] == (widget.id ?? '');
                }).toList();

                if (filteredMessages.isEmpty) {
                  return Center(child: Text('No messages available.'));
                }

                List<Widget> messageWidgets = filteredMessages.map((message) {
                  final messageText = message['text'];

                  return ListTile(
                    title: Text("${messageText}"),
                  );
                }).toList();

                return ListView(children: messageWidgets);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter your message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}