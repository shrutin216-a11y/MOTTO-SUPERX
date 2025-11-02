import 'package:flutter/material.dart';

class AnimatedTravelFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedTravelFAB({super.key, required this.onPressed});

  @override
  State<AnimatedTravelFAB> createState() => _AnimatedTravelFABState();
}

class _AnimatedTravelFABState extends State<AnimatedTravelFAB>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for icon
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulsing circle
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 70 * _pulseAnimation.value,
              height: 70 * _pulseAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 44, 187, 173).withOpacity(0.3),
                    const Color.fromARGB(255, 44, 187, 173).withOpacity(0.1),
                  ],
                ),
              ),
            );
          },
        ),
        // Main FAB
        FloatingActionButton.extended(
          onPressed: widget.onPressed,
          backgroundColor: const Color.fromARGB(255, 44, 187, 173),
          elevation: 6,
          icon: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.14159,
                child: const Icon(
                  Icons.travel_explore,
                  color: Colors.white,
                  size: 24,
                ),
              );
            },
          ),
          label: const Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// Usage: Replace your floatingActionButton with this:
/*
floatingActionButton: AnimatedTravelFAB(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TravelChatbotPage()),
    );
  },
),
*/
