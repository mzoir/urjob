import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String? id;

  const ChatPage({super.key, required this.receiverId, this.id});

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

  Widget buildColoredLines(String message) {
    List<String> lines = message.split('\n');
    List<Color> colors = [Colors.black87, Colors.blue];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            lines[index],
            style: TextStyle(
              color: colors[index % colors.length],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }

  void sendMessage() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty.')),
      );
      return;
    }

    String messageId = widget.id?.isNotEmpty == true
        ? widget.id!
        : _firestore.collection('messages').doc().id;

    try {
      DocumentSnapshot messageDoc =
      await _firestore.collection('messages').doc(messageId).get();

      final user = _auth.currentUser;
      String currentText = _controller.text.trim();

      if (!messageDoc.exists) {
        await _firestore.collection('messages').doc(messageId).set({
          'text': "$currentText: ${user?.email}",
          'sender': loggedInUser?.email,
          'receiver': widget.receiverId,
          'id': messageId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        String existingText = messageDoc['text'];
        String updatedText = "$existingText\n$currentText";
        await _firestore.collection('messages').doc(messageId).set({
          'text': "$updatedText: ${user?.email}",
          'sender': loggedInUser?.email,
          'receiver': widget.receiverId,
          'id': messageId,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _controller.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverId}'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 3,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                final filteredMessages = messages
                    .where((message) => message['id'] == (widget.id ?? ''))
                    .toList();

                if (filteredMessages.isEmpty) {
                  return const Center(child: Text('No messages available.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final message = filteredMessages[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: buildColoredLines(message['text']),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
