import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:motto_app/view/bottom_navigation_screen.dart';

class StartTrip extends StatefulWidget {
  const StartTrip({super.key});

  @override
  State<StartTrip> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTrip>
    with SingleTickerProviderStateMixin {
  int currentStep = 0;
  final PageController _controller = PageController();

  Map<String, dynamic> formData = {
    "destination": "",
    "country": "",
    "groupSize": "",
    "duration": "",
    "boardingPoint": "",
    "startDate": "",
    "endDate": "",
    "mode": "",
    "budget": "",
    "details": "",
    "activities": "",
  };

  final List<String> destinations = [
    "Mount Fuji",
    "Paris",
    "Bali",
    "Tokyo",
    "Dubai",
    "New York",
    "Santorini",
    "Maldives"
  ];

  final List<String> countries = [
    "Japan",
    "France",
    "Indonesia",
    "UAE",
    "USA",
    "Greece",
    "India",
    "Thailand"
  ];

  final List<String> durations = [
    "3 Days",
    "5 Days",
    "7 Days",
    "10 Days",
    "15 Days"
  ];

  final List<String> boardingPoints = [
    "Pune",
    "Mumbai",
    "Delhi",
    "Bangalore",
    "Hyderabad",
    "Chennai"
  ];

  final List<String> modes = ["Car", "Aeroplane", "Train", "Cruise"];

  final List<String> budgets = [
    "₹5000 - ₹8000",
    "₹8000 - ₹15000",
    "₹15000 - ₹25000",
    "₹25000+"
  ];

  final List<String> activities = [
    "Hiking",
    "Skiing",
    "Beach Relaxation",
    "Sightseeing",
    "Cultural Tour",
    "Wildlife Safari",
    "Scuba Diving",
    "Shopping & Local Markets"
  ];

  List<Map<String, dynamic>> get questions => [
        {
          "key": "destination",
          "label": "Choose your Destination",
          "items": destinations,
          "icon": Icons.landscape
        },
        {
          "key": "country",
          "label": "Select the Country of the Destination",
          "items": countries,
          "icon": Icons.flag
        },
        {
          "key": "groupSize",
          "label": "Select Group Size",
          "items": List<String>.generate(12, (i) => "${i + 1} People"),
          "icon": Icons.group
        },
        {
          "key": "duration",
          "label": "Select Trip Duration",
          "items": durations,
          "icon": Icons.access_time
        },
        {
          "key": "boardingPoint",
          "label": "Select the boarding City",
          "items": boardingPoints,
          "icon": Icons.location_on
        },
        {
          "key": "date",
          "label": "Select Start & End Date",
          "items": [],
          "icon": Icons.calendar_month
        },
        {
          "key": "mode",
          "label": "Preferred Mode of Travel",
          "items": modes,
          "icon": Icons.directions_car
        },
        {
          "key": "budget",
          "label": "Select Budget per person",
          "items": budgets,
          "icon": Icons.currency_rupee
        },
        {
          "key": "details",
          "label": "Enter Trip Details",
          "items": [],
          "icon": Icons.notes
        },
        {
          "key": "activities",
          "label": "Select Preferred Activities",
          "items": activities,
          "icon": Icons.surfing
        },
      ];

  void nextStep() {
    String key = questions[currentStep]["key"];
    var value = formData[key];

    if (key == "date") {
      if (formData["startDate"].isEmpty || formData["endDate"].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select both start and end dates."),
        ));
        return;
      }
    } else if (value == null || value.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill this field before continuing."),
      ));
      return;
    }

    if (currentStep < questions.length - 1) {
      setState(() => currentStep++);
      _controller.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      setState(() => currentStep++);
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      _controller.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BottomNavigationWidget()),
      );
    }
  }

  Widget buildDropdownField(List<String> items, IconData icon, String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.teal.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 12),
              Text("Select an option",
                  style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
          value: formData[key].isEmpty ? null : formData[key],
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child:
                        Text(item, style: GoogleFonts.poppins(fontSize: 16)),
                  ))
              .toList(),
          onChanged: (value) => setState(() => formData[key] = value),
        ),
      ),
    );
  }

  Widget buildDateSelector(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.teal.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 8),
              Text("Select Start & End Date",
                  style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () async {
                    final start = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      initialDate: DateTime.now(),
                    );
                    if (start != null) {
                      setState(() => formData["startDate"] =
                          "${start.day}/${start.month}/${start.year}");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade400),
                  label: Text(
                    formData["startDate"].isEmpty
                        ? "Start Date"
                        : formData["startDate"],
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.date_range, color: Colors.white),
                  onPressed: () async {
                    final end = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      initialDate: DateTime.now(),
                    );
                    if (end != null) {
                      setState(() => formData["endDate"] =
                          "${end.day}/${end.month}/${end.year}");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade400),
                  label: Text(
                    formData["endDate"].isEmpty
                        ? "End Date"
                        : formData["endDate"],
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextInput(IconData icon) {
    return TextField(
      onChanged: (val) => setState(() => formData["details"] = val),
      maxLines: 3,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        hintText: "Enter details about your trip...",
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildQuestion(Map<String, dynamic> q) {
    String key = q["key"];
    String label = q["label"];
    IconData icon = q["icon"];
    List<String> items = List<String>.from(q["items"]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🌈 Gradient Header with Decorative Icons
        Stack(
          children: [
            Container(
              height: 160,
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Plan Your Trip",
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text("Answer a few quick questions to start your journey",
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
            ),

            // ✈️ Decorative Travel Icons
            Positioned(
              top: 35,
              left: 25,
              child: Icon(Icons.flight_takeoff,
                  color: Colors.white.withOpacity(0.2), size: 70),
            ),
            Positioned(
              top: 100,
              right: 40,
              child: Icon(Icons.terrain,
                  color: Colors.white.withOpacity(0.25), size: 60),
            ),
            Positioned(
              bottom: 20,
              left: 80,
              child: Icon(Icons.location_on,
                  color: Colors.white.withOpacity(0.15), size: 65),
            ),
            Positioned(
              top: 20,
              right: 90,
              child: Icon(Icons.train,
                  color: Colors.white.withOpacity(0.2), size: 50),
            ),
          ],
        ),

        // 🧭 Progress + Question Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (currentStep + 1) / questions.length,
                color: Colors.teal,
                backgroundColor: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  "Step ${currentStep + 1} of ${questions.length}",
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
              ),
              const SizedBox(height: 25),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    label,
                    textStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87),
                    speed: const Duration(milliseconds: 60),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              const SizedBox(height: 30),
              if (key == "date") buildDateSelector(icon),
              if (key == "details") buildTextInput(icon),
              if (key != "date" && key != "details")
                buildDropdownField(items, icon, key),
              const SizedBox(height: 40),
              Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: previousStep,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text("← Back",
                            style:
                                GoogleFonts.poppins(color: Colors.teal)),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        currentStep == questions.length - 1
                            ? "Finish"
                            : "Next →",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSummary() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text("Your Trip Summary",
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: formData.entries
                  .map((e) => Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(e.key.toUpperCase(),
                              style: GoogleFonts.poppins(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(e.value,
                              style: GoogleFonts.poppins(fontSize: 15)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child:
                Text("Done", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: questions.length + 1,
        itemBuilder: (context, index) {
          if (index == questions.length) return buildSummary();
          return buildQuestion(questions[index]);
        },
      ),
    );
  }
}