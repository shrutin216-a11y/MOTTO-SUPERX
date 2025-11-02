import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motto_app/controller/shared_preference.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  UserController userController = UserController();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await userController.getUserData();
    setState(() {
      _nameController.text = userController.name;
      _bioController.text = userController.bio;
      _phoneController.text = userController.mob;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = userController.profileImage;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!) ?? imageUrl;
      }

      await userController.setUserData({
        "name": _nameController.text.trim(),
        "bio": _bioController.text.trim(),
        "mob": _phoneController.text.trim(),
        "profileImage": imageUrl,
        "email": FirebaseAuth.instance.currentUser?.email ?? "",
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.teal,
      ));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.teal[50],
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0,
          title: Text("Edit Profile",
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (userController.profileImage.isNotEmpty
                              ? NetworkImage(userController.profileImage)
                              : null) as ImageProvider?,
                      backgroundColor: Colors.grey[300],
                      child: (_imageFile == null &&
                              userController.profileImage.isEmpty)
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.teal),
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                _buildHeading("Name"),
                _buildTextField(
                    icon: Icons.person_outline,
                    controller: _nameController,
                    validator: (v) =>
                        v!.isEmpty ? "Enter your name" : null),
                const SizedBox(height: 20),
                _buildHeading("Phone Number"),
                _buildTextField(
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    validator: (v) =>
                        v!.isEmpty ? "Enter phone number" : null),
                const SizedBox(height: 20),
                _buildHeading("Travel Bio"),
                _buildTextField(
                    icon: Icons.explore_outlined,
                    controller: _bioController,
                    validator: (v) =>
                        v!.isEmpty ? "Enter your travel bio" : null),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    onPressed: _saveChanges,
                    child: Text("Save Changes",
                        style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[800])),
        ),
      );

  Widget _buildTextField({
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      cursorColor: Colors.teal,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const Border
