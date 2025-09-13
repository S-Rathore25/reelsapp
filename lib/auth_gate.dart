import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'reels_page.dart';
import 'login_screen.dart';

// AuthGate is a widget that listens to the user's authentication state
// and shows the appropriate screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to authentication state changes from Firebase.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has no data, it means the user is not logged in.
        if (!snapshot.hasData) {
          // Show the LoginScreen if the user is not authenticated.
          return const LoginScreen();
        }

        // Show the main ReelsPage for authenticated users.
        return const ReelsPage();
      },
    );
  }
}