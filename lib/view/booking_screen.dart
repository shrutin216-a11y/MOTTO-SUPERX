import 'dart:developer';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motto_app/controller/shared_preference.dart';
import 'package:motto_app/view/booking_sucessScreen.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final bool isLoggedIn; // New flag to check login
  final String tripId; // Add this line

  const BookingScreen({
    super.key,
    required this.tripData,
    required this.tripId,
    this.isLoggedIn = false,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _passGender = ["Male", "Female", "Transgender"];
  UserController userControllerobj = UserController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final List<String> _passId = [
    "Aadhar Card",
    "PAN Card",
    "Passport",
    "Driving License",
  ];

  List<int> get passCount {
    int max = widget.tripData['groupSize'] ?? 1;
    return List<int>.generate(max, (index) => index + 1);
  }

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  int selectedTravellers = 1;
  List<PassengerController> passengerControllers = [PassengerController()];

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

  Future<void> submitBooking() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      floatingSnackBar(
        message: "You must log in to book a trip",
        context: context,
        textColor: Colors.white,
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    // Validate all passenger fields
    bool allFilled = passengerControllers.every(
      (p) =>
          p.name.text.isNotEmpty &&
          p.contact.text.isNotEmpty &&
          p.email.text.isNotEmpty &&
          p.age.text.isNotEmpty &&
          p.gender.isNotEmpty &&
          p.idType.isNotEmpty &&
          p.idNum.text.isNotEmpty,
    );

    if (!allFilled) {
      floatingSnackBar(
        message: "Please fill all passenger details",
        context: context,
        textColor: Colors.black,
        backgroundColor: Colors.white,
      );
      return;
    }

    try {
      // Save booking under trip document
      final tripId = widget.tripData['tripId'];
      await FirebaseFirestore.instance
          .collection("trips")
          .doc(widget.tripId) // use the passed tripId
          .collection("bookings")
          .add({
            "bookedBy": currentUser.uid,
            "bookedByEmail": currentUser.email ?? "",
            "passengers": passengerControllers.map((p) {
              return {
                "name": p.name.text,
                "contact": p.contact.text,
                "email": p.email.text,
                "age": p.age.text,
                "gender": p.gender,
                "idType": p.idType,
                "idNumber": p.idNum.text,
              };
            }).toList(),
            "timestamp": FieldValue.serverTimestamp(),
          });

      log("TripBooked Successfully");
      // Navigate to success page
      Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitPage()));
    } catch (e) {
      log("Error saving booking: $e");
      floatingSnackBar(
        message: "Failed to book. Try again!",
        context: context,
        textColor: Colors.white,
        backgroundColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Stack(
        children: [
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
          Positioned(
            top: 50,
            left: 30,
            child: Icon(
              Icons.flight_takeoff,
              color: Colors.white.withOpacity(0.3),
              size: 70,
            ),
          ),
          Positioned(
            right: 40,
            top: 90,
            child: Icon(
              Icons.location_on,
              color: Colors.white.withOpacity(0.2),
              size: 60,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
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
                                    items: passCount,
                                    decoration: CustomDropdownDecoration(
                                      closedFillColor: Colors.grey.shade50,
                                      closedBorderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTravellers =
                                            int.tryParse(value.toString()) ?? 1;
                                        passengerControllers = List.generate(
                                          selectedTravellers,
                                          (_) => PassengerController(),
                                        );
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 18),

                                Column(
                                  children: List.generate(selectedTravellers, (
                                    index,
                                  ) {
                                    final passenger =
                                        passengerControllers[index];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildLabel(
                                          "Passenger ${index + 1} Name",
                                        ),
                                        buildAnimated(
                                          buildTextField(
                                            passenger.name,
                                            "Enter Full Name",
                                            icon: Icons.person,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        buildLabel("Contact Number"),
                                        buildAnimated(
                                          buildTextField(
                                            passenger.contact,
                                            "Enter Mobile Number",
                                            icon: Icons.phone,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        buildLabel("Email"),
                                        buildAnimated(
                                          buildTextField(
                                            passenger.email,
                                            "Enter Email",
                                            icon: Icons.email_outlined,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        buildLabel("Age"),
                                        buildAnimated(
                                          buildTextField(
                                            passenger.age,
                                            "Enter Age",
                                            icon: Icons.cake_outlined,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        buildLabel("Gender"),
                                        buildAnimated(
                                          CustomDropdown(
                                            hintText: "Select Gender",
                                            items: _passGender,
                                            decoration:
                                                CustomDropdownDecoration(
                                                  closedFillColor:
                                                      Colors.grey.shade50,
                                                  closedBorderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                            onChanged: (value) =>
                                                passenger.gender = value
                                                    .toString(),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        buildLabel("Identity Proof"),
                                        buildAnimated(
                                          CustomDropdown(
                                            hintText: "Select Identity Proof",
                                            items: _passId,
                                            decoration:
                                                CustomDropdownDecoration(
                                                  closedFillColor:
                                                      Colors.grey.shade50,
                                                  closedBorderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                            onChanged: (value) =>
                                                passenger.idType = value
                                                    .toString(),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        buildLabel("ID Number"),
                                        buildAnimated(
                                          buildTextField(
                                            passenger.idNum,
                                            "Enter ID Number",
                                            icon: Icons.credit_card,
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                      ],
                                    );
                                  }),
                                ),

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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: InkWell(
                                        onTap: submitBooking,
                                        child: Container(
                                          height: 55,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF009688),
                                                Color(0xFF4DB6AC),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.teal.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Submit",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                            ),
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

  Widget buildAnimated(Widget child) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: 1,
      child: child,
    );
  }

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

  Widget buildTextField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
  }) {
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
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.teal.shade400)
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class PassengerController {
  TextEditingController name = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController age = TextEditingController();
  String gender = "";
  String idType = "";
  TextEditingController idNum = TextEditingController();
}
