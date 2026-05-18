import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,

          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,

          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [Color(0xff12001F), Color(0xff1F1147), Color(0xff2B0A3D)],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // APP ICON
            Container(
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: Colors.deepPurple,

                borderRadius: BorderRadius.circular(30),
              ),

              child: const Icon(
                Icons.chat_bubble,

                color: Colors.white,

                size: 70,
              ),
            ),

            const SizedBox(height: 30),

            // APP NAME
            const Text(
              'Flutter Chat',

              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,

                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Connect with everyone',

              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 50),

            const CircularProgressIndicator(color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
