import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FireAuth extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuth get auth => _auth;
  String _good = "";
  String? _uid;

  String? get uid => _uid;
  String get good => _good;

  Future<void> signUp(String email, String password,String username) async {
    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'Name': username});}
      notifyListeners();
    } catch (e) {
      // Handle the error (e.g., log it)
      rethrow; // Rethrow the error to be caught by the UI
    }
  }

  Future<void> logIn(String email, String password) async {
    try {
      final UserCredential userCredential = await auth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _uid = userCredential.user!.uid;

      _good = '_succeed';
      notifyListeners();
    } catch (e) {
      // Handle the error (e.g., log it)
      rethrow; // Rethrow the error to be caught by the UI
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      // Handle the error (e.g., log it)
      rethrow; // Rethrow the error to be caught by the UI
    }
  }
}