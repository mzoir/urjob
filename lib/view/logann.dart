import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urjob/view/sign.dart';
import 'package:urjob/view/wel.dart';

import '../service/auth.dart';

class LoginPosterPage extends StatefulWidget {
  const LoginPosterPage({super.key});

  @override
  State<LoginPosterPage> createState() => _LoginPosterPageState();
}

class _LoginPosterPageState extends State<LoginPosterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: height * 0.02),
                Image.asset("images/j.jpg", height: height * 0.25, width: width * 0.8),
                SizedBox(height: height * 0.03),
                const Text(
                  'Login as poster',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(height: height * 0.02),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your email' : null,
                ),
                SizedBox(height: height * 0.015),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  obscureText: true,
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your password' : null,
                ),
                SizedBox(height: height * 0.03),
                SizedBox(
                  width: double.infinity,
                  height: height * 0.06,
                  child: ElevatedButton(onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final auth = Provider.of<FireAuth>(context, listen: false);
                      try {
                        await auth.logIn(_emailController.text, _passwordController.text);
                        final verify = auth.auth.currentUser!.emailVerified;

                        if (verify) {
                          final uid = auth.auth.currentUser!.uid;
                          String? role = await auth.getUserRole(uid);

                          if (role == 'Poster') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) =>  WelcomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("This login is for Poster accounts only")),
                            );
                            await auth.logout();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Verify your email")),
                          );
                          await auth.auth.currentUser?.sendEmailVerification();
                          await auth.logout();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Login failed: $e")),
                        );
                      }
                    }
                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Log in', style: TextStyle(color: Colors.white)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to forgot password page
                  },
                  child: const Text('Forgot password?', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: height * 0.0),
                SizedBox(
                  width: double.infinity,
                  height: height * 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Create new account', style: TextStyle(color: Colors.blue)),
                  ),
                ),
                SizedBox(height: height * 0.01),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    );
                  },
                  child: const Text('StartwithoutLog', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
