import 'dart:ui'; // CRITICAL: Required for glassmorphic ImageFilter blurring
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/profile_screen.dart';
import 'package:flutter_chat_app/screens/users_screen.dart';

import 'chats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const ChatsScreen(),
    const UsersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(
              0xFF0F0E13,
            ), // Deep cyberpunk dark background
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC046FF)),
              ),
            ),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(
            0xFF0F0E13,
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Welcome ${user['username']} 👋',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
          ),
          body: screens[currentIndex],

          // --- CYBER GLASS BOTTOM NAVIGATION BAR ---
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 20,
              top: 10,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.04,
                    ), // Matches the dark glass look from image
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        0.08,
                      ), // Light catching edge highlight
                      width: 1.2,
                    ),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    // Making native components transparent to reveal glass Container style
                    backgroundColor: Colors.transparent,
                    elevation: 0,

                    // Theme coloring matched directly to user profile picture glow ring
                    selectedItemColor: const Color(0xFFE386FF),
                    unselectedItemColor: Colors.white38,
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    type: BottomNavigationBarType.fixed,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.chat_bubble_outline),
                        activeIcon: Icon(Icons.chat_bubble),
                        label: 'Chats',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.people_outline),
                        activeIcon: Icon(Icons.people),
                        label: 'Users',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
