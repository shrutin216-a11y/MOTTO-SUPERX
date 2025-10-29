import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motto_app/controller/placesApi_controller.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:motto_app/controller/tripDatabase.dart';

import 'package:motto_app/controller/shared_preference.dart';

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
  final ImagePicker _picker = ImagePicker();
  UserController userControllerObj = UserController();

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

  final List<String> modes = ["Car", "Aeroplane", "Train", "Cruise"];
  final List<String> activities = [
    "Hiking",
    "Skiing",
    "Beach Relaxation",
    "Sightseeing",
    "Cultural Tour",
    "Wildlife Safari",
    "Scuba Diving",
    "Shopping & Local Markets",
  ];

  List<Map<String, dynamic>> get questions => [
    {
      "key": "destination",
      "label": "Choose your Destination",
      "type": "dropdown",

      "icon": Icons.landscape,
    },
    {
      "key": "groupSize",
      "label": "Select Group Size",
      "type": "counter",
      "icon": Icons.group,
    },
    {
      "key": "date",
      "label": "Select Start & End Date",
      "type": "date",
      "icon": Icons.calendar_month,
    },
    {
      "key": "boardingPoint",
      "label": "Select Boarding City",
      "type": "dropdown",

      "icon": Icons.location_on,
    },
    {
      "key": "mode",
      "label": "Preferred Mode of Travel",
      "type": "multiselect",
      "items": modes,
      "icon": Icons.directions_car,
    },
    {
      "key": "budget",
      "label": "Enter Budget per Person",
      "type": "budget",
      "icon": Icons.currency_rupee,
    },
    {
      "key": "details",
      "label": "Trip Details",
      "type": "text",
      "icon": Icons.notes,
    },
    {
      "key": "activities",
      "label": "Preferred Activities",
      "type": "multiselect",
      "items": activities,
      "icon": Icons.surfing,
    },
    {
      "key": "photos",
      "label": "Upload 4 Photos of Destination",
      "type": "image",
      "icon": Icons.photo,
    },
  ];

  // ------------------ VALIDATION & NAVIGATION ------------------
  void nextStep() async {
    String key = questions[currentStep]["key"];
    if (!_validateStep(key)) return;

    if (currentStep < questions.length - 1) {
      setState(() => currentStep++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ Get logged-in user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // ✅ Upload photos to Firebase Storage
        List<File> localPhotos = List<File>.from(formData["photos"]);
        List<String> uploadedPhotoUrls = [];

        for (File photo in localPhotos) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference ref = FirebaseStorage.instance.ref().child(
            'trip_images/$fileName.jpg',
          );

          UploadTask uploadTask = ref.putFile(photo);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          uploadedPhotoUrls.add(downloadUrl);
        }

        // ✅ Prepare trip data
        final trip = {
          'destination': formData["destination"],
          'groupSize': formData["groupSize"],
          'startDate': formData["startDate"],
          'endDate': formData["endDate"],
          'boardingPoint': formData["boardingPoint"],
          'mode': (formData["mode"] as List).join(", "),
          'minBudget': formData["minBudget"],
          'maxBudget': formData["maxBudget"],
          'details': formData["details"],
          'activities': (formData["activities"] as List).join(", "),
          'photoPaths': uploadedPhotoUrls.join(", "), // for SQLite
          'userId': user.uid,
          'userEmail': user.email ?? '',
        };

        // ✅ Save to SQLite
        final TripDatabase localDb = TripDatabase();
        await localDb.insertTrip(trip);
        log("✅ Trip added locally to SQLite");

        // ✅ Save to Firebase Firestore
        await FirebaseFirestore.instance.collection("trips").add({
          "destination": formData["destination"],
          "groupSize": formData["groupSize"],
          "startDate": formData["startDate"],
          "endDate": formData["endDate"],
          "boardingPoint": formData["boardingPoint"],
          "mode": List<String>.from(formData["mode"]),
          "minBudget": formData["minBudget"],
          "maxBudget": formData["maxBudget"],
          "details": formData["details"],
          "activities": List<String>.from(formData["activities"]),
          "photoPaths": uploadedPhotoUrls, // store as list in Firestore
          "userId": user.uid,
          "userEmail": user.email ?? "",
          "createdAt": FieldValue.serverTimestamp(),
          "status": "active",
        });

        await FirebaseFirestore.instance.collection('notifications').add({
          'title': 'New Trip Added!',
          'body':
              'A new trip to ${formData["destination"]} has been posted. Check it out!',
          'timestamp': FieldValue.serverTimestamp(),
        });
//         FirebaseFirestore.instance.collection('fcmTokens').get().then((snapshot) {
//   for (var doc in snapshot.docs) {
//     final token = doc.data()['token'];
//     if (token != null) {
//       sendFcmMessage(token, "New Trip Posted!", "A trip to ${formData['destination']} added");
//     }
//   }
// });

        log("✅ Trip added to Firebase");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip posted successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavigationWidget()),
        );
      } else {
        _showSnack("User not logged in, please sign in first.");
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavigationWidget()),
      );
    }
  }

  bool _validateStep(String key) {
    switch (key) {
      case "destination":
      case "boardingPoint":
        if (formData[key].toString().isEmpty) {
          _showSnack(
            "Please select ${key == "destination" ? "destination" : "boarding city"}",
          );
          return false;
        }
        break;
      case "groupSize":
        if (formData[key] <= 0) {
          _showSnack("Please select a valid group size");
          return false;
        }
        break;
      case "date":
        if (formData["startDate"].isEmpty || formData["endDate"].isEmpty) {
          _showSnack("Please select start and end dates");
          return false;
        }
        break;
      case "mode":
      case "activities":
        if ((formData[key] as List).isEmpty) {
          _showSnack("Please select at least one $key");
          return false;
        }
        break;
      case "budget":
        if (formData["minBudget"].toString().isEmpty ||
            formData["maxBudget"].toString().isEmpty) {
          _showSnack("Please enter min & max budget");
          return false;
        }
        break;
      case "details":
        if ((formData["details"]
                .toString()
                .trim()
                .split(RegExp(r'\s+'))
                .length) <
            50) {
          _showSnack("Please enter at least 50 words");
          return false;
        }
        break;
      case "photos":
        if ((formData[key] as List<File>).isEmpty) {
          _showSnack("Please upload at least one photo");
          return false;
        }
        break;
    }
    return true;
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ------------------ WIDGET BUILDERS ------------------
  InputDecoration _inputDecoration(IconData icon, String hint) =>
      InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );

  Widget buildPlaceField(String key, IconData icon) {
    final isDest = key == "destination";
    final controller = isDest
        ? PlaceSearchController.destinationController
        : PlaceSearchController.boardingController;
    final suggestions = isDest
        ? PlaceSearchController.destinationSuggestions
        : PlaceSearchController.boardingSuggestions;

    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: (val) => PlaceSearchController.onChange(
            val,
            isDest ? "destination" : "boarding",
          ),
          decoration: _inputDecoration(
            icon,
            "Search ${isDest ? "destination" : "boarding city"}...",
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<List<dynamic>>(
          valueListenable: suggestions,
          builder: (context, list, _) {
            if (list.isEmpty) return const SizedBox.shrink();
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final text = list[i]['description'];
                  return ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.teal,
                    ),
                    title: Text(text, style: GoogleFonts.poppins(fontSize: 15)),
                    onTap: () {
                      setState(() => formData[key] = text);
                      controller.text = text;
                      list.clear();
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildCounterField(String key) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        iconSize: 40,
        onPressed: () => setState(
          () => formData[key] = formData[key] > 1 ? formData[key] - 1 : 1,
        ),
        icon: const Icon(Icons.remove_circle_outline, color: Colors.teal),
      ),
      Text(
        "${formData[key]}",
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      IconButton(
        iconSize: 40,
        onPressed: () => setState(() => formData[key]++),
        icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
      ),
    ],
  );

  Widget buildDateSelector() => Row(
    children: ["startDate", "endDate"].map((d) {
      return Expanded(
        child: ElevatedButton.icon(
          icon: Icon(
            d == "startDate" ? Icons.calendar_today : Icons.date_range,
            color: Colors.white,
          ),
          label: Text(
            formData[d].isEmpty
                ? (d == "startDate" ? "Start Date" : "End Date")
                : formData[d],
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              initialDate: DateTime.now(),
            );
            if (date != null) {
              setState(
                () => formData[d] = "${date.day}/${date.month}/${date.year}",
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade400,
          ),
        ),
      );
    }).toList(),
  );

  Widget buildTextInput(String key, IconData icon, {bool isDetails = false}) =>
      TextField(
        onChanged: (val) => setState(() => formData[key] = val),
        maxLines: isDetails ? 5 : 1,
        keyboardType: key.contains("Budget")
            ? TextInputType.number
            : TextInputType.text,
        decoration: _inputDecoration(
          icon,
          isDetails ? "Enter trip details..." : "Enter amount",
        ),
      );

  Widget buildBudgetInput() => Row(
    children: ["minBudget", "maxBudget"].map((k) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: k == "minBudget" ? 12 : 0),
          child: buildTextInput(k, Icons.currency_rupee),
        ),
      );
    }).toList(),
  );

  Widget buildMultiSelect(String key, List<String> items, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  key == "mode" ? "Select Travel Mode(s)" : "Select Activities",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: items
                  .map(
                    (item) => FilterChip(
                      label: Text(item, style: GoogleFonts.poppins()),
                      selected: (formData[key] as List<String>).contains(item),
                      onSelected: (sel) {
                        setState(
                          () => sel
                              ? (formData[key] as List<String>).add(item)
                              : (formData[key] as List<String>).remove(item),
                        );
                      },
                      selectedColor: Colors.teal.shade200,
                      checkmarkColor: Colors.white,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );

  Widget buildPhotoPicker() => Column(
    children: [
      ElevatedButton.icon(
        icon: const Icon(Icons.add_a_photo),
        label: const Text("Pick Photo"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        onPressed: () async {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
          );
          if (image != null && (formData["photos"] as List<File>).length < 4) {
            setState(
              () => (formData["photos"] as List<File>).add(File(image.path)),
            );
          }
        },
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: (formData["photos"] as List<File>)
            .map((f) => Image.file(f, width: 80, height: 80, fit: BoxFit.cover))
            .toList(),
      ),
    ],
  );

  Widget buildQuestion(Map<String, dynamic> q) {
    final key = q["key"];
    final type = q["type"];
    final items = q["items"] ?? [];
    final icon = q["icon"];
    final label = q["label"];
    Widget field;
    switch (type) {
      case "dropdown":
        field = buildPlaceField(key, icon);
        break;
      case "counter":
        field = buildCounterField(key);
        break;
      case "date":
        field = buildDateSelector();
        break;
      case "text":
        field = buildTextInput(key, icon, isDetails: true);
        break;
      case "budget":
        field = buildBudgetInput();
        break;
      case "multiselect":
        field = buildMultiSelect(key, List<String>.from(items), icon);
        break;
      case "image":
        field = buildPhotoPicker();
        break;
      default:
        field = const SizedBox();
        break;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    "Plan Your Trip",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Answer a few quick questions to start your journey",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
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
                  minHeight: 6,
                ),
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    "Step ${currentStep + 1} of ${questions.length}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                field,
                const SizedBox(height: 100),
              ],
            ),
          ),
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
            itemBuilder: (_, i) => buildQuestion(questions[i]),
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
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "← Back",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        currentStep == questions.length - 1
                            ? "Submit"
                            : "Next →",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
}
