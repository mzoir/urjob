import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urjob/service/auth.dart';
import 'package:urjob/view/home.dart';
import 'package:urjob/view/home_page.dart';
import 'package:urjob/view/wel.dart';
import 'package:urjob/viewmodels/UserViewModel.dart';
import 'firebase_options.dart';
import 'view/log.dart'; // Make sure this file exists and defines UrjobPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FireAuth()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrJob App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SessionChecker(),
    );
  }
}

/// This widget checks if a user is logged in and redirects accordingly
class SessionChecker extends StatelessWidget {
  const SessionChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return  HomePage(); // user is logged in
        } else {
          return const UrjobPage(); // user not logged in
        }
      },
    );
  }
}
