import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motto_app/controller/shared_preference.dart';

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

  // ✅ Initialize controllers safely
  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await userController.getSharedPrefData();
    setState(() {
      _nameController.text = userController.name;
      _bioController.text = userController.bio;
      _phoneController.text = userController.mob;
      if (userController.profileImage.isNotEmpty) {
        _imageFile = File(userController.profileImage);
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await userController.setSharedPrefData({
        "name": _nameController.text.trim(),
        "bio": _bioController.text.trim(),
        "mob": _phoneController.text.trim(),
        "profileImage": _imageFile?.path ?? userController.profileImage,
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
          automaticallyImplyLeading: false,
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
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: _imageFile == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
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
          borderSide: const BorderSide(color: Colors.teal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
    );
  }
}