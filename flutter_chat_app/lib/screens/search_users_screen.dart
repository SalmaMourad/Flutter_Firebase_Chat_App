import 'dart:ui'; // CRITICAL: Required for ImageFilter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Search Users')),
        body: Column(
          children: [
            // SEARCH FIELD
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by username',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),

                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            // USERS LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  // ERROR
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  // LOADING
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;

                  // FILTER USERS
                  final filteredUsers = users.where((user) {
                    // HIDE CURRENT USER
                    if (user['uid'] == currentUser.uid) {
                      return false;
                    }

                    // SAFE USERNAME
                    String username = '';
                    if (user.data().toString().contains('username')) {
                      username = user['username'].toString().toLowerCase();
                    }

                    return username.contains(searchText);
                  }).toList();

                  // EMPTY SEARCH
                  if (searchText.isNotEmpty && filteredUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    );
                  }

                  // EMPTY SCREEN
                  if (searchText.isEmpty) {
                    return const Center(
                      child: Text(
                        'Search for users 👋',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];

                      // --- START OF GLASS USER CARD ---
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.06,
                                ), // Matches receiver glass look
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1.2,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.15,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  user['username'] ?? 'No Username',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  user['email'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: const Icon(
                                  Icons.chat,
                                  color: Colors.white70,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        receiverEmail: user['email'],
                                        receiverId: user['uid'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                      // --- END OF GLASS USER CARD ---
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
