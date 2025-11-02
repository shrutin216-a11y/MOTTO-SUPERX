import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motto_app/controller/travel_assistant_service.dart';
import 'package:motto_app/controller/location_service.dart';
import 'package:motto_app/view/Home_screen.dart';

class TravelChatbotPage extends StatefulWidget {
  const TravelChatbotPage({super.key});

  @override
  State<TravelChatbotPage> createState() => _TravelChatbotPageState();
}

class _TravelChatbotPageState extends State<TravelChatbotPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late TravelAssistantService _assistant;
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  HomeScreen homeScreenObj = HomeScreen();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();

    _assistant = TravelAssistantService(
      'AIzaSyCtMXtIMWP6gGbBcPnuKCLXn5-HAz8SXcU',
      'AIzaSyCYoHiDx-m5e7v7Spq0sRM_oN-AQNuWktY',
    );
    _messages.add({
      'bot':
          'Hi! I\'m your travel assistant. Ask me about travel destinations, places to visit, tourist attractions, or say "near me" to find places nearby!',
      'type': 'text',
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isTravelRelated(String text) {
    final travelKeywords = [
      'travel',
      'trip',
      'visit',
      'destination',
      'tourist',
      'tourism',
      'vacation',
      'holiday',
      'place',
      'city',
      'country',
      'attraction',
      'sightseeing',
      'tour',
      'explore',
      'beach',
      'mountain',
      'hotel',
      'restaurant',
      'museum',
      'park',
      'temple',
      'church',
      'monument',
      'near me',
      'nearby',
      'around',
      'recommend',
      'suggest',
      'where',
      'best places',
      'things to do',
      'activities',
      'landmark',
      'heritage',
      'historical',
      'cultural',
      'adventure',
      'nature',
      'scenic',
      'view',
      'fort',
      'lake',
      'waterfall',
      'dam',
      'cave',
      'hill',
      'valley',
      'garden',
      'zoo',
      'resort',
      'trek',
      'hiking',
      'camping',
      'spot',
    ];

    final lowerText = text.toLowerCase();

    if (travelKeywords.any((keyword) => lowerText.contains(keyword))) {
      return true;
    }

    final words = text.trim().split(' ');
    if (words.length <= 3 && words.isNotEmpty) {
      if (text.trim().isNotEmpty &&
          text.trim()[0] == text.trim()[0].toUpperCase()) {
        return true;
      }
    }

    return false;
  }

  Future<void> _handleUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'user': text, 'type': 'text'});
      _controller.clear();
      _loading = true;
    });
    _scrollToBottom();

    if (!_isTravelRelated(text)) {
      setState(() {
        _messages.add({
          'bot':
              'I\'m specialized in travel assistance! Please ask me about:\n'
              '• Travel destinations and places to visit\n'
              '• Tourist attractions and landmarks\n'
              '• Things to do in a city\n'
              '• Nearby places (say "near me")\n'
              '• Travel recommendations',
          'type': 'text',
        });
        _loading = false;
      });
      _scrollToBottom();
      return;
    }

    if (text.toLowerCase().contains('near me')) {
      try {
        final pos = await LocationService.getCurrentLocation();
        final placesData = await _assistant.getNearbyPlacesWithImages(
          pos.latitude,
          pos.longitude,
        );
        setState(() {
          _messages.add({
            'bot': 'Here are some amazing places near you:',
            'type': 'places',
            'places': placesData,
          });
        });
      } catch (e) {
        setState(() {
          _messages.add({
            'bot':
                'Could not access your location. Please enable location services or type a specific city name.',
            'type': 'text',
          });
        });
      }
    } else {
      final enhancedPrompt =
          'You are a travel assistant. Only provide information about travel destinations, places to visit, tourist attractions, and travel-related topics. User query: $text';

      final replyData = await _assistant.generateTravelReplyWithImages(
        enhancedPrompt,
      );

      setState(() {
        if (replyData['places'] != null && replyData['places'].isNotEmpty) {
          _messages.add({
            'bot': replyData['text'] ?? 'Here are some places you might like:',
            'type': 'places',
            'places': replyData['places'],
          });
        } else {
          _messages.add({
            'bot':
                replyData['text'] ??
                'Let me help you find great travel destinations!',
            'type': 'text',
          });
        }
      });
    }

    setState(() => _loading = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Gradient header matching MyPostedTripsScreen
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
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
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
                          "Travel Assistant",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Discover amazing places to visit",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Chat messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final msg = _messages[i];
                        if (msg.containsKey('user')) {
                          return _buildUserMessage(msg['user']!);
                        } else {
                          if (msg['type'] == 'places') {
                            return _buildBotMessageWithPlaces(
                              msg['bot']!,
                              msg['places'],
                            );
                          } else {
                            return _buildBotMessage(msg['bot']!);
                          }
                        }
                      },
                    ),
                  ),

                  if (_loading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Finding places...',
                              style: GoogleFonts.poppins(
                                color: Colors.teal.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  _buildInputArea(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 50),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 50),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotMessageWithPlaces(String text, List<dynamic> places) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotMessage(text),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return _buildPlaceCard(
                  place['name'] ?? 'Unknown Place',
                  place['imageUrl'] ?? '',
                  place['description'] ?? '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(String name, String imageUrl, String description) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130,
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey.shade600,
                          size: 40,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 130,
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.place,
                      color: Colors.grey.shade600,
                      size: 40,
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_city, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    hintText: 'Ask about destinations...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() => _controller.clear());
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                  onSubmitted: _handleUserMessage,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => _handleUserMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
