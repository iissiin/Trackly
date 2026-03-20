import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class homeScreen extends StatelessWidget {
  const homeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: Text(
          'Привет, ${user?.displayName ?? 'друг'}! 👋',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
