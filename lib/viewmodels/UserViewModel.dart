import 'package:urjob/service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:urjob/model/client.dart';





class UserViewModel extends ChangeNotifier {
  static final User? _auth = FirebaseAuth.instance.currentUser;


  Clients client = Clients(username: "", email: _auth!.email.toString(), id:_auth!.uid.toString() , emailverified: _auth!.emailVerified);


}