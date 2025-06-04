import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urjob/service/auth.dart';
import 'package:urjob/view/home.dart';
import 'package:urjob/view/home_page.dart';
import 'package:urjob/view/log.dart'; // Login // Poster home
import 'firebase_options.dart';
import 'viewmodels/UserViewModel.dart';

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
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: Colors.deepPurple,
      ),

      debugShowCheckedModeBanner: false,
      home: const SessionChecker(),
    );
  }
}

class SessionChecker extends StatelessWidget {
  const SessionChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData && snapshot.data != null) {
          final uid = snapshot.data!.uid;

          return FutureBuilder<String?>(
            future: Provider.of<FireAuth>(context, listen: false).getUserRole(uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              } else if (roleSnapshot.hasData) {
                final role = roleSnapshot.data;
                if (role == "Worker") {
                  return const Home();
                } else if (role == "Poster") {
                  return  HomePage();
                } else {
                  return const Scaffold(body: Center(child: Text("Unknown role")));
                }
              } else {
                return const Scaffold(body: Center(child: Text("Failed to fetch role")));
              }
            },
          );
        } else {
          return const UrjobPage(); // Not logged in
        }
      },
    );
  }
}
