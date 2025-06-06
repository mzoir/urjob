import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:urjob/service/auth.dart';
import 'MessagesLis.dart';
import 'chatme.dart';
import 'log.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AnnoncesPage(),
    MessagesListPage(),
    const Center(child: Text('Messages Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FireAuth>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Urjob'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const ListTile(leading: Icon(Icons.home), title: Text('Home')),
            const ListTile(leading: Icon(Icons.message), title: Text('Messages')),
            const ListTile(leading: Icon(Icons.favorite), title: Text('Favorites')),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log out'),
              onTap: () async {
                await auth.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => UrjobPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_2), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart), label: 'Fav'),
        ],
      ),
    );
  }
}

class AnnoncesPage extends StatelessWidget {
  const AnnoncesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('annonces')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.docs ?? [];

        if (data.isEmpty) {
          return const Center(child: Text('No annonces available.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final annonceData = data[index].data() as Map<String, dynamic>;

            final title = annonceData['title'] ?? 'No title';
            final desc = annonceData['description'] ?? '';
            final location = annonceData['location'] ?? '';
            final category = annonceData.containsKey('category') ? annonceData['category'] : 'Other';
            final budget = annonceData['budget']?.toString() ?? 'Not specified';
            final email = annonceData['userId'].toString();

            return Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 8),
                    Text(desc, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(fontSize: 14, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Budget: $budget MAD', style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(category, style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final currentUser = FirebaseAuth.instance.currentUser;
                          final senderId = currentUser?.email;
                          final receiverId = email;

                          if (senderId == null || receiverId == null) return;

                          final chatId = [senderId, receiverId]..sort();
                          final combinedId = chatId.join('_');

                          final docRef = FirebaseFirestore.instance.collection('conversations').doc(combinedId);
                          final doc = await docRef.get();

                          if (!doc.exists) {
                            await docRef.set({
                              'users': [senderId, receiverId],
                              'lastMessage': '',
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(receiverId: receiverId, id: combinedId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send),
                        label: const Text("Contact"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
