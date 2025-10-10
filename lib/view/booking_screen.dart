import 'dart:developer';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motto_app/view/booking_sucessScreen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final List<int> _passCount = [1, 2, 3, 4, 5];
  final List<String> _passGender = ["Male", "Female", "Transgender"];
  final List<String> _passId = [
    "Aadhar Card",
    "PAN Card",
    "Passport",
    "Driving License",
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController idNumController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Stack(
        children: [
          // 🌈 Gradient Header (fixed)
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            height: 230,
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

          // ✈️ Decorative icons in header
          Positioned(
            top: 50,
            left: 30,
            child: Icon(Icons.flight_takeoff,
                color: Colors.white.withOpacity(0.3), size: 70),
          ),
          Positioned(
            right: 40,
            top: 90,
            child: Icon(Icons.location_on,
                color: Colors.white.withOpacity(0.2), size: 60),
          ),

          // 📋 Content layout
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),

                // 🏷️ Fixed Header
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Text(
                        "Booking Form",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Plan your journey with comfort and confidence ✈️",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 🧾 Scrollable Form Section
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.15),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("No. of Travellers"),
                                buildAnimated(
                                  CustomDropdown(
                                    hintText: "Select number of passengers",
                                    items: _passCount,
                                    decoration: CustomDropdownDecoration(
                                      closedFillColor: Colors.grey.shade50,
                                      closedBorderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    onChanged: (value) =>
                                        log('Traveller count: $value'),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                buildLabel("Passenger Name"),
                                buildAnimated(buildTextField(
                                  nameController,
                                  "Enter Full Name",
                                  icon: Icons.person,
                                )),
                                const SizedBox(height: 18),

                                buildLabel("Contact Number"),
                                buildAnimated(buildTextField(
                                  contactController,
                                  "Enter Mobile Number",
                                  icon: Icons.phone,
                                )),
                                const SizedBox(height: 18),

                                buildLabel("Email"),
                                buildAnimated(buildTextField(
                                  emailController,
                                  "Enter Email Address",
                                  icon: Icons.email_outlined,
                                )),
                                const SizedBox(height: 18),

                                buildLabel("Age"),
                                buildAnimated(buildTextField(
                                  ageController,
                                  "Enter Age",
                                  icon: Icons.cake_outlined,
                                )),
                                const SizedBox(height: 18),

                                buildLabel("Gender"),
                                buildAnimated(
                                  CustomDropdown(
                                    hintText: "Select Gender",
                                    items: _passGender,
                                    decoration: CustomDropdownDecoration(
                                      closedFillColor: Colors.grey.shade50,
                                      closedBorderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    onChanged: (value) =>
                                        log('Gender: $value'),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                buildLabel("Identity Proof"),
                                buildAnimated(
                                  CustomDropdown(
                                    hintText: "Select Identity Proof",
                                    items: _passId,
                                    decoration: CustomDropdownDecoration(
                                      closedFillColor: Colors.grey.shade50,
                                      closedBorderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    onChanged: (value) =>
                                        log('ID Type: $value'),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                buildLabel("ID Number"),
                                buildAnimated(buildTextField(
                                  idNumController,
                                  "Enter ID Number",
                                  icon: Icons.credit_card,
                                )),
                                const SizedBox(height: 25),

                                // ✅ Buttons Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          minimumSize: const Size(0, 55),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: Text("Cancel",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18)),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (nameController.text.isNotEmpty &&
                                              contactController
                                                  .text.isNotEmpty &&
                                              emailController
                                                  .text.isNotEmpty &&
                                              ageController
                                                  .text.isNotEmpty &&
                                              idNumController
                                                  .text.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      SubmitPage()),
                                            );
                                          } else {
                                            floatingSnackBar(
                                              message:
                                                  "Please fill all details",
                                              context: context,
                                              textColor: Colors.black,
                                              textStyle: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                              duration:
                                                  const Duration(seconds: 2),
                                              backgroundColor: Colors.white,
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 55,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF009688),
                                                Color(0xFF4DB6AC)
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.teal
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text("Submit",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🪶 Field animation wrapper
  Widget buildAnimated(Widget child) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: 1,
      child: child,
    );
  }

  // 🏷️ Label Builder
  Widget buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.teal.shade800,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  // 🧾 Custom TextField
  Widget buildTextField(TextEditingController controller, String hint,
      {IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.teal.shade400) : null,
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }
}
