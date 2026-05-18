import 'dart:ui'; // CRITICAL: Required for glassmorphic ImageFilter blurring
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0F0E13,
      ), // Deep cyberpunk dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'All Users',
          style: TextStyle(
            color: Color(
              0xFFE386FF,
            ), // Neon purple title matching theme accents
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC046FF)),
              ),
            );
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              // --- GLASS CONTAINER CARD ---
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.04,
                        ), // Subtle dark glass tint
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(
                            0.08,
                          ), // Sleek edge highlight
                          width: 1.2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFE386FF),
                                Color(0xFFC046FF),
                              ], // Profile frame gradient
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFF15141A),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                        ),
                        title: Text(
                          user['username'] ?? 'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            user['email'] ?? '',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white30,
                        ),
                      ),
                    ),
                  ),
                ),
              );
              // --- END GLASS CONTAINER ---
            },
          );
        },
      ),
    );
  }
}
