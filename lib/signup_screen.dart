import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

// A stateful widget for the user registration screen.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  // Controllers for the email and password text fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Global key to validate the form.
  final _formKey = GlobalKey<FormState>();
  // Flag to indicate if a signup process is in progress.
  bool _isLoading = false;

  // Animation controller for fade-in effect.
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    // Define the fade animation.
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    // Start the animation.
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources.
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles the user signup process.
  Future<void> _signup() async {
    // If the form is not valid, do nothing.
    if (!_formKey.currentState!.validate()) return;
    // Set loading state to true.
    setState(() => _isLoading = true);
    try {
      // Attempt to create a new user with email and password using Firebase Auth.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // After successful signup, AuthGate will navigate to the main app screen.
    } on FirebaseAuthException catch (e) {
      // If an error occurs, show a SnackBar with the error message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message ?? 'Signup failed'),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      // Set loading state back to false when the process is complete.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply a gradient background.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2B32B2), Color(0xFF141E30)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Screen title.
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Email input field.
                    _buildCustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    // Password input field.
                    _buildCustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 40),
                    // Show a progress indicator or the signup button.
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _buildSignupButton(),
                    const SizedBox(height: 20),
                    // Button to navigate to the login screen.
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // A helper widget to build a styled text form field.
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8E44AD), width: 2),
        ),
      ),
      // Validator for the input fields.
      validator: (value) {
        if (labelText == 'Password') {
          if (value == null || value.length < 6) {
            return 'Password must be at least 6 characters';
          }
        } else if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }

  // A helper widget to build the signup button.
  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _signup,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: const Color(0xFF8E44AD), // Vibrant button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  // A helper widget to build the button that navigates to the login screen.
  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        // Replace the current screen with the LoginScreen using a fade transition.
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: const Text(
        'Already have an account? Login',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}