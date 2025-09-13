import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_gate.dart'; // Import AuthGate instead of ReelsPage

// A stateful widget for the splash screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for managing animations.
  late AnimationController _controller;
  // Animation for the fade-in effect.
  late Animation<double> _fadeAnimation;
  // Animation for the scaling effect.
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a 2-second duration.
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the fade animation curve.
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Define the scale animation from 0.5 to 1.0.
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start the animations.
    _controller.forward();

    // Add a listener to the animation status.
    _controller.addStatusListener((status) {
      // When the animation is complete, navigate to the next screen.
      if (status == AnimationStatus.completed) {
        Timer(const Duration(milliseconds: 500), () {
          // Replace the current screen with the AuthGate.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              // ## CHANGE MADE HERE ##
              // Navigate to AuthGate, which will decide whether to show
              // the LoginScreen or ReelsPage based on auth state.
              builder: (context) => const AuthGate(),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose the animation controller to free up resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply a gradient background.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2c3e50), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Apply scale and fade transitions to the logo.
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    // Display the app logo.
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/img.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Apply fade transition to the app title.
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Personal Reel Gallery',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Apply fade transition to the progress indicator.
              FadeTransition(
                opacity: _fadeAnimation,
                child: const CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}