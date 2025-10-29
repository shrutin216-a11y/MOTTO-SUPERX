import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserListScreen(),
    ),
  );
}

// 🧩 USER LIST SCREEN — shows all users and opens chat when tapped
class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Chats",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .where((u) => u.id != currentUserId)
              .toList();

          if (users.isEmpty) {
            return Center(
              child: Text(
                "No other users found.",
                style: GoogleFonts.quicksand(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  user['name'] ?? "Unknown User",
                  style: GoogleFonts.quicksand(fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverId: user.id,
                        receiverName: user['name'] ?? "User",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// 💬 CHAT SCREEN — real-time one-to-one chat between two users
class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String currentUserId = _auth.currentUser!.uid;
    String message = _messageController.text.trim();
    _messageController.clear();

    // Create a unique chat room ID (both users share the same)
    List<String> ids = [currentUserId, widget.receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Store the message
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
          'senderId': currentUserId,
          'receiverId': widget.receiverId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Store metadata for chat list
    await _firestore
        .collection('user_chats')
        .doc(currentUserId)
        .collection('contacts')
        .doc(widget.receiverId)
        .set({
          'chatRoomId': chatRoomId,
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
          'name': widget.receiverName,
        });

    await _firestore
        .collection('user_chats')
        .doc(widget.receiverId)
        .collection('contacts')
        .doc(currentUserId)
        .set({
          'chatRoomId': chatRoomId,
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
          'name': _auth.currentUser!.displayName ?? "You",
        });
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, widget.receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.receiverName,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueAccent.withOpacity(0.85)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          msg['message'],
                          style: GoogleFonts.quicksand(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input box
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: const Offset(0, -1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.quicksand(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.quicksand(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
