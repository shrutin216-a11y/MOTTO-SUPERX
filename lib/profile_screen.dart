import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motto_app/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DummyScreen(title: "Edit Profile"),
                ),
              );
            },
          ),
        ],
      ),

      // Body
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(height: 10),

                  // Traveler Name
                  const Text(
                    "Traveler Name",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  const Text(
                    "Adventure Enthusiast",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Phone
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        "+91 95634 67567",
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Email
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        "traveler.mottoapp@gmail.com",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  const Divider(thickness: 1, color: Colors.grey),

                  // Menu Options with Functionality
                  _buildMenuItem(
                    Icons.favorite_border,
                    "Favourites",
                    context,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DummyScreen(title: "Favourites"),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(Icons.reviews, "Reviews", context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const DummyScreen(title: "Reviews"),
                      ),
                    );
                  }),
                  _buildMenuItem(
                    Icons.feedback_outlined,
                    "Feedback",
                    context,
                    () {
                      _showFeedbackDialog(context);
                    },
                  ),
                  _buildMenuItem(
                    Icons.add_location_alt_outlined,
                    "Create Trip",
                    context,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DummyScreen(title: "Create Trip"),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.language,
                    "Preferred Language",
                    context,
                    () {
                      _showLanguageSelector(context);
                    },
                  ),
                  _buildMenuItem(Icons.settings, "Settings", context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const DummyScreen(title: "Settings"),
                      ),
                    );
                  }),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.green),
                      title: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () async {
                        bool confirm = await _showLogoutConfirmation(context);
                        if (confirm) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();

                          await FirebaseAuth.instance.signOut();

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧱 Reusable Menu Item Widget
  Widget _buildMenuItem(
    IconData icon,
    String title,
    BuildContext context,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // 🗣 Feedback Dialog
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
                  backgroundColor: Colors.black,
                ),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // 🌐 Language Selector
  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Select Preferred Language"),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Language set to English")),
              );
            },
            child: const Text("English"),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Language set to Marathi")),
              );
            },
            child: const Text("Marathi"),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Language set to Hindi")),
              );
            },
            child: const Text("Hindi"),
          ),
        ],
      ),
    );
  }

  // 🚪 Logout Confirmation Dialog
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

// 🧩 Dummy Screen for Navigation Preview
class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.green),
      body: Center(),
    );
  }
}
