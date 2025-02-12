import 'package:book_store/home_screen.dart';
import 'package:book_store/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show a loading indicator while checking auth status
        } else if (snapshot.hasError) {
          return Center(child: Text('Something went wrong: ${snapshot.error}')); // Display the error message
        } else if (snapshot.hasData) {
          return HomeScreen(); // User is logged in, show home screen
        } else {
          return LoginScreen(); // User is not logged in, show login screen
        }
      },
    );
  }
}