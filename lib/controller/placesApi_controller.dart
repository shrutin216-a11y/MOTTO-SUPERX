import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class PlaceSearchController {
  // Uuid generator instance (✅ Correct way)
  static final Uuid _uuid = Uuid();

  // Destination Controller
  static final TextEditingController destinationController =
      TextEditingController();
  static final ValueNotifier<List<dynamic>> destinationSuggestions =
      ValueNotifier<List<dynamic>>([]);
  static final String _destinationSessionToken = _uuid.v4();

  // Boarding Controller
  static final TextEditingController boardingController =
      TextEditingController();
  static final ValueNotifier<List<dynamic>> boardingSuggestions =
      ValueNotifier<List<dynamic>>([]);
  static final String _boardingSessionToken = _uuid.v4();

  // ✅ Your Google Places API Key
  static const String _apiKey =
      "AIzaSyCYoHiDx-m5e7v7Spq0sRM_oN-AQNuWktY"; // Replace this with your actual API key

  // Called whenever user types in the search box
  static void onChange(String input, String type) {
    if (input.isNotEmpty) {
      _fetchSuggestions(input, type);
    } else {
      if (type == "destination") {
        destinationSuggestions.value = [];
      } else if (type == "boarding") {
        boardingSuggestions.value = [];
      }
    }
  }

  // Fetch suggestions from Google Places API
  static Future<void> _fetchSuggestions(String input, String type) async {
    try {
      const String baseUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      final String sessionToken = type == "destination"
          ? _destinationSessionToken
          : _boardingSessionToken;

      final Uri request = Uri.parse(
        "$baseUrl?input=$input&key=$_apiKey&sessiontoken=$sessionToken&components=country:in",
      );

      final response = await http.get(request);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['predictions'] != null) {
        if (type == "destination") {
          destinationSuggestions.value = data['predictions'];
        } else if (type == "boarding") {
          boardingSuggestions.value = data['predictions'];
        }
      } else {
        if (type == "destination") {
          destinationSuggestions.value = [];
        } else if (type == "boarding") {
          boardingSuggestions.value = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
    }
  }
}
