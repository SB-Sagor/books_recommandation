import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_store/screens/home_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final supabase = Supabase.instance.client;
  bool isEmailVerified = false;

  Future<void> checkEmailVerification() async {
    await supabase.auth.refreshSession(); // Refresh session to get updated user info
    final user = supabase.auth.currentUser;

    if (user != null && user.emailConfirmedAt != null) {
      setState(() {
        isEmailVerified = true;
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()),);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email not verified yet. Please check your inbox.")),);
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
              "We have sent a verification link to your email.\nPlease check your inbox.",
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please check your inbox. Supabase sends the email automatically.")),
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
