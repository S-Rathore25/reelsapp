// ## Ab AuthGate Banayein ##
// File: lib/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'reels_page.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Agar user login nahi hai, to LoginScreen dikhao
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Agar user login hai, to ReelsPage dikhao
        return const ReelsPage();
      },
    );
  }
}