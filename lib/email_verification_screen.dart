import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> checkEmailVerification() async {
    User? user = _auth.currentUser;
    await user?.reload(); // Reload user data
    if (user != null && user.emailVerified) {
      setState(() {
        isEmailVerified = true;
      });

      // Navigate to Home Page if verified
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email not verified yet. Please check your inbox.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Verify Your Email",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "We have sent an email verification link. Please check your inbox.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: checkEmailVerification,
              child: Text("Reload & Check"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                await _auth.currentUser?.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Verification email sent again.")),
                );
              },
              child: Text("Resend Verification Email"),
            ),
          ],
        ),
      ),
    );
  }
}
