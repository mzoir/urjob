import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urjob/service/auth.dart';
import 'package:urjob/view/sign.dart';
import 'package:urjob/view/wel.dart';
import 'package:urjob/view/welu.dart';
import 'forpass.dart';
import 'home_page.dart';
import '../main.dart';
import 'logann.dart';

class UrjobPage extends StatefulWidget {
  const UrjobPage({super.key});

  @override
  State<UrjobPage> createState() => _UrjobPageState();
}

class _UrjobPageState extends State<UrjobPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
        backgroundColor: const Color(0xFF1D3557), // Deep modern blue
        leading: IconButton(
          onPressed: () => SystemNavigator.pop(),
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Worker Login',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.04),
                // KEEP THE IMAGE
                Image.asset("images/j.jpg", height: height * 0.25, width: width * 0.8),
                SizedBox(height: height * 0.04),

                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D3557),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
                SizedBox(height: height * 0.04),

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
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter your email' : null,
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
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
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
                          final uid = auth.auth.currentUser!.uid;
                          String? role = await auth.getUserRole(uid);

                          if (role == 'Worker') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => WelcomeU()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("This login is for Worker accounts only")),
                            );
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
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgetPasswordPage())),
                  child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF1D3557))),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPosterPage())),
                  child: const Text('Log as poster', style: TextStyle(color: Colors.redAccent)),
                ),
                SizedBox(height: height * 0.01),

                // Create New Account
                SizedBox(
                  width: double.infinity,
                  height: height * 0.06,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignPage())),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1D3557)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Create new account', style: TextStyle(color: Color(0xFF1D3557), fontSize: 16)),
                  ),
                ),

                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
