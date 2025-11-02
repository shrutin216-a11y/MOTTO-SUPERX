import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class TravelAssistantService {
  final GenerativeModel model;
  final String placesApiKey; // Google Places API key

  TravelAssistantService(String geminiApiKey, this.placesApiKey)
    : model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: geminiApiKey);

  Future<String> generateChatReply(String userMessage) async {
    final content = [Content.text(userMessage)];
    final response = await model.generateContent(content);
    return response.text ?? 'Sorry, I couldnt generate a response.';
  }

  Future<List<String>> getNearbyPlaces(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&type=tourist_attraction&key=$placesApiKey';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final places = data['results'] as List;
      return places.take(5).map((p) => p['name'] as String).toList();
    } else {
      throw Exception('Failed to fetch nearby places');
    }
  }

  Future<List<Map<String, String>>> getNearbyPlacesWithImages(
    double lat,
    double lng,
  ) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&type=tourist_attraction&key=$placesApiKey';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final places = data['results'] as List;

        List<Map<String, String>> result = [];
        for (var place in places.take(5)) {
          String imageUrl = '';

          // Get photo URL if available
          if (place['photos'] != null && (place['photos'] as List).isNotEmpty) {
            final photoReference = place['photos'][0]['photo_reference'];
            imageUrl =
                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$placesApiKey';
          }

          result.add({
            'name': place['name'] as String? ?? 'Unknown Place',
            'imageUrl': imageUrl,
            'description': place['vicinity'] as String? ?? '',
          });
        }
        return result;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> generateTravelReplyWithImages(
    String query,
  ) async {
    try {
      // Use Gemini API with system prompt to ensure travel-only responses
      final prompt = '''You are a travel assistant. The user asked: "$query"

Provide helpful travel information and suggest 3-5 specific tourist attractions or famous places.

If they mentioned a city/location name, list famous attractions IN THAT LOCATION.
If they asked a general question, suggest relevant destinations.

Format your response EXACTLY like this:
REPLY: [Your brief helpful response]
PLACES: Full Name of Place 1, Full Name of Place 2, Full Name of Place 3

Examples:
- For "Lonavala": List places like "Bhushi Dam, Lonavala", "Tiger's Leap, Lonavala", "Karla Caves, Lonavala"
- For "Paris": List places like "Eiffel Tower, Paris", "Louvre Museum, Paris", "Arc de Triomphe, Paris"
- Always include the city/location name with each place for better search results

User query: $query''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text ?? '';

      // Extract reply and place names
      String replyText = '';
      List<String> placeNames = [];

      if (text.contains('REPLY:') && text.contains('PLACES:')) {
        final parts = text.split('PLACES:');
        replyText = parts[0].replaceAll('REPLY:', '').trim();

        if (parts.length > 1) {
          placeNames = parts[1]
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e.length > 2)
              .toList();
        }
      } else {
        // If format not followed, try to extract place names manually
        replyText = text;
        // Try to use the query itself as a place to search
        if (query.split(' ').length <= 3) {
          placeNames = [query];
        }
      }

      // Fetch images for those places using Google Places API
      List<Map<String, String>> places = [];
      for (var placeName in placeNames.take(5)) {
        try {
          final placeData = await _searchPlaceByName(placeName);
          if (placeData != null) {
            places.add(placeData);
          }
        } catch (e) {
          // Skip places that fail to fetch
          continue;
        }
      }

      // If no places found but query looks like a location, search for tourist attractions there
      if (places.isEmpty && query.split(' ').length <= 3) {
        final locationPlaces = await _searchTouristAttractionsInLocation(query);
        places.addAll(locationPlaces);
      }

      // Return map with 'text' and 'places' (list of place objects)
      return {
        'text': replyText.isNotEmpty
            ? replyText
            : 'Here are some great places in $query!',
        'places': places,
      };
    } catch (e) {
      print('Error in generateTravelReplyWithImages: $e');
      return {
        'text':
            'I can help you discover amazing travel destinations! Try asking about specific cities or attractions.',
        'places': <Map<String, String>>[],
      };
    }
  }

  // New helper method to search for tourist attractions in a location
  Future<List<Map<String, String>>> _searchTouristAttractionsInLocation(
    String location,
  ) async {
    try {
      // First, get the place_id for the location
      final searchUrl =
          'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${Uri.encodeComponent(location)}&inputtype=textquery&fields=place_id,geometry&key=$placesApiKey';
      final searchRes = await http.get(Uri.parse(searchUrl));

      if (searchRes.statusCode == 200) {
        final searchData = jsonDecode(searchRes.body);
        final candidates = searchData['candidates'] as List;

        if (candidates.isNotEmpty) {
          final geometry = candidates[0]['geometry'];
          final location = geometry['location'];
          final lat = location['lat'];
          final lng = location['lng'];

          // Now search for tourist attractions nearby
          final nearbyUrl =
              'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=10000&type=tourist_attraction&key=$placesApiKey';
          final nearbyRes = await http.get(Uri.parse(nearbyUrl));

          if (nearbyRes.statusCode == 200) {
            final nearbyData = jsonDecode(nearbyRes.body);
            final results = nearbyData['results'] as List;

            List<Map<String, String>> places = [];
            for (var place in results.take(5)) {
              String imageUrl = '';

              if (place['photos'] != null &&
                  (place['photos'] as List).isNotEmpty) {
                final photoReference = place['photos'][0]['photo_reference'];
                imageUrl =
                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$placesApiKey';
              }

              places.add({
                'name': place['name'] as String? ?? 'Unknown Place',
                'imageUrl': imageUrl,
                'description': place['vicinity'] as String? ?? '',
              });
            }
            return places;
          }
        }
      }
      return [];
    } catch (e) {
      print('Error searching tourist attractions: $e');
      return [];
    }
  }

  // Helper method to search for a place by name
  Future<Map<String, String>?> _searchPlaceByName(String placeName) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${Uri.encodeComponent(placeName)}&inputtype=textquery&fields=name,photos,formatted_address&key=$placesApiKey';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final candidates = data['candidates'] as List;

        if (candidates.isNotEmpty) {
          final place = candidates[0];
          String imageUrl = '';

          if (place['photos'] != null && (place['photos'] as List).isNotEmpty) {
            final photoReference = place['photos'][0]['photo_reference'];
            imageUrl =
                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$placesApiKey';
          }

          return {
            'name': place['name'] as String? ?? placeName,
            'imageUrl': imageUrl,
            'description': place['formatted_address'] as String? ?? '',
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
