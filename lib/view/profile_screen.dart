import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motto_app/controller/shared_preference.dart';
import 'package:motto_app/view/Favourites.dart';
import 'package:motto_app/view/Reviews.dart';
import 'package:motto_app/view/StartTrip.dart';
import 'package:motto_app/view/bottom_navigation_screen.dart';
import 'package:motto_app/view/edit.dart';
import 'package:motto_app/view/history.dart';
import 'package:motto_app/view/login_screen.dart';
import 'package:motto_app/view/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  UserController userController = UserController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    getData();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getData() async {
    await userController.getSharedPrefData();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Stack(
        children: [
          // 🌈 Gradient Header
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BFA5), Color(0xFF4DB6AC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
          ),

          // Decorative Icons
          Positioned(
            top: 40,
            left: 25,
            child: Icon(Icons.person_pin_circle,
                color: Colors.white.withOpacity(0.2), size: 80),
          ),
          Positioned(
            top: 100,
            right: 40,
            child: Icon(Icons.map_outlined,
                color: Colors.white.withOpacity(0.25), size: 60),
          ),

          // 📄 Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),

                    // 🏷️ Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return BottomNavigationWidget();
                            })),
                        ),
                        Text(
                          "Profile",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Your travel identity at a glance ",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 👤 Profile Info Card (Bigger Height)
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Circle (No default image)
                          Stack(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: _imageFile != null
                                      ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _imageFile == null
                                    ? const Center(
                                        child: Icon(Icons.person,
                                            size: 50, color: Colors.grey),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.teal,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 20),

                          // Name, Phone, Email
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Traveler Name",
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Adventure Enthusiast",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text("+91 95634 67567",
                                        style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: Colors.black87)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        userController.email,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // 🧭 Menu Options Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(Icons.add_location_alt_outlined,
                              "Create Trip", context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StartTrip()),
                            );
                          }),
                          _buildMenuItem(
                              Icons.favorite_border, "Favourites", context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Favourites()),
                            );
                          }),
                          _buildMenuItem(Icons.history, "History", context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HistoryScreen()),
                            );
                          }),
                          _buildMenuItem(Icons.reviews, "Reviews", context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Reviews()),
                            );
                          }),
                          _buildMenuItem(Icons.feedback_outlined, "Feedback",
                              context, () {
                            _showFeedbackDialog(context);
                          }),
                          _buildMenuItem(
                              Icons.settings, "Settings", context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingScreen()),
                            );
                          }),
                          const Divider(),
                          GestureDetector(
                            onTap: () async {
                              bool confirm =
                                  await _showLogoutConfirmation(context);
                              if (confirm) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.clear();
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.logout,
                                      color: Colors.redAccent),
                                  const SizedBox(width: 10),
                                  Text("Logout",
                                      style: GoogleFonts.poppins(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Menu Item Widget
  Widget _buildMenuItem(
      IconData icon, String title, BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal[700]),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Feedback Dialog
  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Feedback"),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: "Share your feedback here...",
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thanks for your feedback!"),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // Logout Confirmation Dialog
  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    bool confirm = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              confirm = true;
              Navigator.pop(context);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
    return confirm;
  }
}
