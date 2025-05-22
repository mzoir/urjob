import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urjob/main.dart';

import 'home_page.dart';
import 'log.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
        appBar: AppBar(

          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon( Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      // green border simulation
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image (local asset or network image)
              Image.asset(
                'images/640.webp', // Make sure to add this asset
                height: 250,
              ),
              const SizedBox(height: 2),
              const Text(
                'Welcome to urjob',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF5C4BFE),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'where we connect\nemployees & recruiters',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF2F2F8),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  HomePage())
                );
                  // Navigate to next screen
                },
                child: const Text(
                  'Get started',
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}