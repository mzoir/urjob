import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'log.dart'; // Ensure this file exists and contains `LoginPage`.

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 50.0),
          Image.asset(
            '12.jpg',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 50.0),
          const Text(
            'Forgot password',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _forgetPasswordFormKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight. bold,
                        ),
                        decoration: InputDecoration(
                          icon: const Icon(Icons.email),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              width: 2.0,
                              color: Color(0xffa9a9a8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              width: 2.0,
                              color: Color(0xff023dff),
                            ),
                          ),
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        cursorColor: const Color(0xff08d9ac),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Add more validation if needed
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _handleForgetPassword,
                        child: const Text('Send',style:TextStyle(color:Colors.white)),
                        style : ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 0, 240, 100),
                          fixedSize: const Size(250, 50),

                        ),
                      ),
                      const SizedBox(height: 200),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  UrjobPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Back to login',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleForgetPassword() async {
    if (_forgetPasswordFormKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent! Check your email.')),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }
}