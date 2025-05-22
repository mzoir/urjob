import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Annocepro extends StatefulWidget {
  const Annocepro({super.key});

  @override
  State<Annocepro> createState() => _AnnoceproState();
}

class _AnnoceproState extends State<Annocepro> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String category = "Cleaning";

  final CollectionReference annonces =
  FirebaseFirestore.instance.collection('annonces');

  Future<void> postAnnonce() async {
    try {
      await annonces.add({
        'title': _titleController.text,
        'description': _descController.text,
        'location': _locationController.text,
        'budget': double.tryParse(_budgetController.text) ?? 0.0,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce posted successfully!')),
      );

      _titleController.clear();
      _descController.clear();
      _locationController.clear();
      _budgetController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.blue),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Post Annonce"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: inputStyle('Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: inputStyle('Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: inputStyle('Location'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budgetController,
              decoration: inputStyle('Budget (MAD)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              onChanged: (val) => setState(() => category = val!),
              items: ['Cleaning', 'Plumbing', 'Delivery', 'Design']
                  .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
                  .toList(),
              decoration: inputStyle('Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: postAnnonce,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Post Annonce",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
