import 'package:book_store/screens/bottom_NavigationBar.dart';
import 'package:book_store/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthCheck extends StatelessWidget {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = supabase.auth.currentSession;

        if (session != null) {
          return BottomNavigationbar(); // ✅ Logged in
        } else {
          return LoginScreen(); // ✅ Not logged in
        }
      },
    );
  }
}
