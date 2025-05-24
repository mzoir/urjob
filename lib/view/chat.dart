import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPo extends StatefulWidget {
  final String receiverId;
  final String id;
  const ChatPo({super.key, required this.receiverId, required this.id});

  @override
  State<ChatPo> createState() => _ChatPoState();
}

class _ChatPoState extends State<ChatPo> {
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
  Widget buildColoredText(String message) {
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
            ),
          ),
        );
      }),
    );
  }


  void sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    DocumentSnapshot messageDoc =
    await _firestore.collection('messages').doc(widget.id).get();

    final user = _auth.currentUser;
    String currentText = _controller.text.trim();

    if (!messageDoc.exists) {
      await _firestore.collection('messages').doc(widget.id).set({
        'text': "$currentText: ${user?.email}",
        'sender': loggedInUser?.email,
        'receiver': widget.receiverId,
        'id': widget.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      String existingText = messageDoc['text'];
      String updatedText = "$existingText\n$currentText";
      await _firestore.collection('messages').doc(widget.id).set({
        'text': "$updatedText: ${user?.email}",
        'sender': loggedInUser?.email,
        'receiver': widget.receiverId,
        'id': widget.id,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.receiverId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
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
                    .where((message) => message['id'] == widget.id)
                    .toList();

                if (filteredMessages.isEmpty) {
                  return const Center(child: Text('No messages available.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(10),
                  children: filteredMessages.map((message) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: buildColoredText(message['text']),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
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
