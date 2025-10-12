import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
    "groupSize": 1,
    "startDate": "",
    "endDate": "",
    "boardingPoint": "",
    "mode": <String>[],
    "minBudget": "",
    "maxBudget": "",
    "details": "",
    "activities": <String>[],
    "photos": <File>[],
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

  final List<String> boardingPoints = [
    "Pune",
    "Mumbai",
    "Delhi",
    "Bangalore",
    "Hyderabad",
    "Chennai"
  ];

  final List<String> modes = ["Car", "Aeroplane", "Train", "Cruise"];

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

  final ImagePicker _picker = ImagePicker();

  void nextStep() {
    String key = questions[currentStep]["key"];

    // Validations for each question
    if (key == "destination" && (formData[key] == null || formData[key].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please choose a destination."),
      ));
      return;
    }
    if (key == "groupSize" && formData[key] <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select a valid group size."),
      ));
      return;
    }
    if (key == "date" && (formData["startDate"].isEmpty || formData["endDate"].isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select both start and end dates."),
      ));
      return;
    }
    if (key == "boardingPoint" && (formData[key] == null || formData[key].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select a boarding city."),
      ));
      return;
    }
    if (key == "mode" && (formData[key] as List<String>).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select at least one travel mode."),
      ));
      return;
    }
    if (key == "budget" &&
        (formData["minBudget"].toString().isEmpty || formData["maxBudget"].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter both min and max budget."),
      ));
      return;
    }
    if (key == "details") {
      final words = formData["details"].toString().trim().split(RegExp(r'\s+'));
      if (words.length < 50) { // Only trip details validation
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter at least 50 words in trip details."),
        ));
        return;
      }
    }
    if (key == "activities" && (formData[key] as List<String>).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select at least one activity."),
      ));
      return;
    }
    if (key == "photos" && (formData[key] as List<File>).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please upload at least one photo."),
      ));
      return;
    }

    // Move to next step
    if (currentStep < questions.length - 1) {
      setState(() => currentStep++);
      _controller.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      setState(() => currentStep++);
      // TODO: Handle final submission
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

  List<Map<String, dynamic>> get questions => [
        {
          "key": "destination",
          "label": "Choose your Destination",
          "type": "dropdown",
          "items": destinations,
          "icon": Icons.landscape
        },
        {
          "key": "groupSize",
          "label": "Select Group Size",
          "type": "counter",
          "icon": Icons.group
        },
        {
          "key": "date",
          "label": "Select Start & End Date",
          "type": "date",
          "icon": Icons.calendar_month
        },
        {
          "key": "boardingPoint",
          "label": "Select Boarding City",
          "type": "dropdown",
          "items": boardingPoints,
          "icon": Icons.location_on
        },
        {
          "key": "mode",
          "label": "Preferred Mode of Travel",
          "type": "multiselect",
          "items": modes,
          "icon": Icons.directions_car
        },
        {
          "key": "budget",
          "label": "Enter Budget per Person",
          "type": "budget",
          "icon": Icons.currency_rupee
        },
        {
          "key": "details",
          "label": "Trip Details",
          "type": "text",
          "icon": Icons.notes
        },
        {
          "key": "activities",
          "label": "Preferred Activities",
          "type": "multiselect",
          "items": activities,
          "icon": Icons.surfing
        },
        {
          "key": "photos",
          "label": "Upload 4 Photos of Destination",
          "type": "image",
          "icon": Icons.photo
        },
      ];

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

  Widget buildCounterField(String key) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            iconSize: 40,
            onPressed: () {
              if (formData[key] > 1) setState(() => formData[key]--);
            },
            icon: const Icon(Icons.remove_circle_outline, color: Colors.teal)),
        Text(
          "${formData[key]}",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        IconButton(
            iconSize: 40,
            onPressed: () {
              setState(() => formData[key]++);
            },
            icon: const Icon(Icons.add_circle_outline, color: Colors.teal)),
      ],
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

  Widget buildTextInput(String key, IconData icon) {
    return TextField(
      onChanged: (val) => setState(() => formData[key] = val),
      maxLines: key == "details" ? 5 : 1,
      keyboardType:
          key.contains("Budget") ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        hintText: key == "details" ? "Enter trip details..." : "Enter amount",
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

  Widget buildBudgetInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) => formData["minBudget"] = val,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.currency_rupee, color: Colors.teal),
              hintText: "Min Budget",
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            onChanged: (val) => formData["maxBudget"] = val,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.currency_rupee, color: Colors.teal),
              hintText: "Max Budget",
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMultiSelect(String key, List<String> items, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              key == "mode" ? "Select Travel Mode(s)" : "Select Activities",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: items
                .map((item) => FilterChip(
                      label: Text(item, style: GoogleFonts.poppins()),
                      selected: (formData[key] as List<String>).contains(item),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            (formData[key] as List<String>).add(item);
                          } else {
                            (formData[key] as List<String>).remove(item);
                          }
                        });
                      },
                      selectedColor: Colors.teal.shade200,
                      checkmarkColor: Colors.white,
                    ))
                .toList(),
          )
        ],
      ),
    );
  }

  Widget buildPhotoPicker() {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_a_photo),
          label: const Text("Pick Photo"),
          onPressed: () async {
            final XFile? image =
                await _picker.pickImage(source: ImageSource.gallery);
            if (image != null && (formData["photos"] as List<File>).length < 4) {
              setState(() => (formData["photos"] as List<File>).add(File(image.path)));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: (formData["photos"] as List<File>)
              .map((file) => Image.file(file, width: 80, height: 80, fit: BoxFit.cover))
              .toList(),
        )
      ],
    );
  }

  Widget buildQuestion(Map<String, dynamic> q) {
    String key = q["key"];
    String label = q["label"];
    IconData icon = q["icon"];
    String type = q["type"];
    List<String> items = q.containsKey("items") ? List<String>.from(q["items"]) : [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            ],
          ),
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
                        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 25),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      label,
                      textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                      speed: const Duration(milliseconds: 60),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
                const SizedBox(height: 30),
                if (type == "dropdown") buildDropdownField(items, icon, key),
                if (type == "counter") buildCounterField(key),
                if (type == "date") buildDateSelector(icon),
                if (type == "text" || type == "number") buildTextInput(key, icon),
                if (type == "budget") buildBudgetInput(),
                if (type == "multiselect") buildMultiSelect(key, items, icon),
                if (type == "image") buildPhotoPicker(),
                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return buildQuestion(questions[index]);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
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
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.teal,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: nextStep,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: Text(currentStep == questions.length - 1 ? "Submit" : "Next →",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
