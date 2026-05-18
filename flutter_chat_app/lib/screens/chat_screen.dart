import 'dart:ui'; // 1. CRITICAL: Added for ImageFilter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    List<String> ids = [currentUser.uid, widget.receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    String message = messageController.text.trim();

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
          'senderId': currentUser.uid,
          'receiverId': widget.receiverId,
          'message': message,
          'timestamp': Timestamp.now(),
        });

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set({
          'participants': ids,
          'lastMessage': message,
          'lastMessageTime': Timestamp.now(),
        }, SetOptions(merge: true));

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    List<String> ids = [currentUser.uid, widget.receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(widget.receiverEmail[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverEmail,
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start chatting 👋',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isMe = message['senderId'] == currentUser.uid;
                    Timestamp timestamp = message['timestamp'];
                    DateTime time = timestamp.toDate();
                    String formattedTime = DateFormat('hh:mm a').format(time);

                    return Container(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // --- START OF GLASS CHAT BUBBLE ---
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 5),
                              bottomRight: Radius.circular(isMe ? 5 : 20),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 8.0,
                                sigmaY: 8.0,
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  // Setup conditional glass backgrounds
                                  gradient: isMe
                                      ? LinearGradient(
                                          colors: [
                                            const Color.fromARGB(
                                              255,
                                              119,
                                              0,
                                              179,
                                            ).withOpacity(
                                              0.75,
                                            ), // Vibrant Purple-Pink
                                            const Color.fromARGB(
                                              255,
                                              220,
                                              106,
                                              255,
                                            ).withOpacity(0.65),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null, // No gradient for receiver
                                  color: isMe
                                      ? null
                                      : Colors.white.withOpacity(
                                          0.06,
                                        ), // Very dark/subtle frosted glass for receiver
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(isMe ? 20 : 5),
                                    bottomRight: Radius.circular(isMe ? 5 : 20),
                                  ),
                                  border: Border.all(
                                    color: isMe
                                        ? Colors.white.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.12),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      message['message'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors
                                            .white, // Ensure white text is highly readable
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isMe
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // --- END OF GLASS CHAT BUBBLE ---
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: messageController,
              style: const TextStyle(
                color: Colors.white,
              ), // Ensures typed text is visible
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),

                // Glass styling for the input box
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),

                // Fixed Suffix Icons
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // 1. CRITICAL: Prevents the row from expanding infinitely
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.emoji_emotions_outlined,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          // Emoji action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic, color: Colors.white70),
                        onPressed: () {
                          // Voice action
                        },
                      ),
                      const SizedBox(width: 4),
                      // Cleaned up Send Button
                      IconButton(
                        onPressed: sendMessage,
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFC046FF,
                          ).withOpacity(0.8), // Matches sender glass bubble
                          padding: const EdgeInsets.all(10),
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
}
