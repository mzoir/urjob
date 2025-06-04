import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urjob/view/sign.dart';
import 'package:urjob/view/wel.dart';

import '../service/auth.dart';
import 'forpass.dart';

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
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D3557),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Poster Login',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: height * 0.03),
                Image.asset("images/j.jpg", height: height * 0.25, width: width * 0.8),
                SizedBox(height: height * 0.04),
                const Text(
                  'Login as Poster',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1D3557)),
                ),
                SizedBox(height: height * 0.015),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFF1D3557)),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF1D3557)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF457B9D), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1D3557)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your email' : null,
                ),
                SizedBox(height: height * 0.025),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFF1D3557)),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF1D3557)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF457B9D), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1D3557)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your password' : null,
                ),
                SizedBox(height: height * 0.04),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: height * 0.06,
                  child: ElevatedButton(
                    onPressed: () async {
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
                                MaterialPageRoute(builder: (_) => WelcomeScreen()),
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
                      backgroundColor: const Color(0xFF1D3557),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Log in', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ForgetPasswordPage()),
                    );
                    // Navigate to forgot password page
                  },
                  child: const Text('Forgot password?', style: TextStyle(color: Color(
                      0xFFEE0707))),
                ),

                SizedBox(height: height * 0.01),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: height * 0.06,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1D3557)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Create new account', style: TextStyle(color: Color(0xFF1D3557), fontSize: 16)),
                  ),
                ),
                SizedBox(height: height * 0.001),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
