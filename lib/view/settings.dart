import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motto_app/view/AboutUsPage.dart';
import 'package:motto_app/view/edit.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  bool _notifications = true;
  bool _location = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

          // Decorative icons
          Positioned(
            top: 50,
            left: 25,
            child: Icon(
              Icons.settings,
              color: Colors.white.withOpacity(0.2),
              size: 80,
            ),
          ),
          Positioned(
            top: 90,
            right: 40,
            child: Icon(
              Icons.tune,
              color: Colors.white.withOpacity(0.25),
              size: 60,
            ),
          ),

          // MAIN CONTENT
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          "Settings",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    // This space prevents overlap
                    const SizedBox(height: 80),

                    //Settings Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Icons.notifications_active_outlined,
                            title: "Push Notifications",
                            value: _notifications,
                            onChanged: (val) {
                              setState(() {
                                _notifications = val;
                              });
                            },
                          ),
                          _divider(),
                          _buildSwitchTile(
                            icon: Icons.location_on_outlined,
                            title: "Location Access",
                            value: _location,
                            onChanged: (val) {
                              setState(() {
                                _location = val;
                              });
                            },
                          ),
                          _divider(),
                          _buildOptionTile(
                            icon: Icons.manage_accounts_outlined,
                            title: "Manage Account",
                            onTap: () {
                              _showManageAccountDialog(context);
                            },
                          ),
                          _divider(),
                          _buildOptionTile(
                            icon: Icons.lock_outline,
                            title: "Change Password",
                            onTap: () {
                              _showChangePasswordDialog(context);
                            },
                          ),
                          _divider(),
                          _buildOptionTile(
                            icon: Icons.privacy_tip_outlined,
                            title: "Privacy & Security",
                            onTap: () {
                              _showSnack("Privacy settings tapped");
                            },
                          ),
                          _divider(),
                          _buildOptionTile(
                            icon: Icons.language_outlined,
                            title: "Language",
                            trailing: const Text(
                              "English",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              _showSnack("Language settings tapped");
                            },
                          ),
                          _divider(),
                          _buildOptionTile(
                            icon: Icons.help_outline,
                            title: "Help & Support",
                            onTap: () {
                              _showSnack("Help & Support tapped");
                            },
                          ),
                          _divider(),
                          _buildOptionTile(
                            icon: Icons.info_outline,
                            title: "About App",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutUsPage(),
                                ),
                              );
                              ;
                            },
                          ),
                          _divider(),
                          _buildOptionTile(
                            icon: Icons.question_answer_outlined,
                            title: "FAQ",
                            onTap: () {
                              _showFAQDialog(context);
                            },
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

  Widget _divider() => const Divider(height: 1, color: Color(0xFFE0E0E0));

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal[700]),
          const SizedBox(width: 16),
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
          Switch(
            activeThumbColor: Colors.teal,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.teal.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal[700]),
            const SizedBox(width: 16),
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
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.teal));
  }

  // Change Password Dialog
  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController oldPassword = TextEditingController();
    final TextEditingController newPassword = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassword,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Current Password"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPassword,
              obscureText: true,
              decoration: const InputDecoration(hintText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack("Password changed successfully!");
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // Manage Account Dialog
  void _showManageAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Manage Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Edit Personal Info"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteAccount(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to permanently delete your account?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack("Account deleted successfully!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // About App
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("About App"),
        content: Text(
          "MOTTO (Meets Others To Travel Out)\n\nVersion 1.0.0\n\nConnecting travelers for meaningful journeys together.",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // FAQ
  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("FAQ"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _faqItem(
                "1. How can I create a trip?",
                "Go to 'Create Trip' from your profile menu and fill out trip details.",
              ),
              _faqItem(
                "2. How do I join other users’ trips?",
                "Browse available trips and send a request to join. The trip creator will review and accept requests.",
              ),
              _faqItem(
                "3. Is my personal data secure?",
                "Yes, MOTTO uses Firebase Authentication and secured data handling for all users.",
              ),
              _faqItem(
                "4. How can I report an issue?",
                "Visit 'Help & Support' to contact our support team or send feedback.",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
